---
title: 製作窮人的 Postfix Completion visual studio 外掛
date: 2021-02-07 01:43:38
tags:
- visual studio
- vsix
- postfix completion
- vim
---
&nbsp;
<!-- more -->

### 內文
一直很想用看看 ReSharper 可惜沒錢, 尤其是 Postfix Completion 這個功能 , 看了一下 vscode 有[這東東](https://marketplace.visualstudio.com/items?itemName=ipatalas.vscode-postfix-ts) 跟 [eclipse](https://github.com/trylimits/Eclipse-Postfix-Code-Completion) 都有 but visual studio 竟然沒有!?

上網爬看看 open source 好像也沒看到類似的 extension , 準備要放棄的時候看到 [Emmet.net](https://github.com/sergey-rybalkin/Emmet.net) 有個 ZenSharp 的功能 
裡面原理在 text buffer 裡面操作修改 , 差不多算是有一線曙光搞得出 Postfix Completion 不過要自己刻

核心類別為 [ZenSharpCommandTarget](https://github.com/sergey-rybalkin/Emmet.net/blob/master/Emmet/EditorExtensions/ZenSharpCommandTarget.cs) ,  [CommandTargetBase](https://github.com/sergey-rybalkin/Emmet.net/blob/ab614a9a2d32396e16bfd4fce2cd9cc39f9bc574/Emmet/EditorExtensions/CommandTargetBase.cs) , [ViewCreationListener](https://github.com/sergey-rybalkin/Emmet.net/blob/master/Emmet/EditorExtensions/ViewCreationListener.cs)
最主要要修改 `ZenSharpCommandTarget` 內的 `exec` 函數這裡簡單實作一下 , 有空在修完善 , 不過有個致命缺點就是無法像 ReSharper 一樣秀出自動提示那種選單
查了一堆資料也 try 了半天好像都會被預設的 visual studio intellisense 吃掉!? 又懶得研究 code snippet 就先這樣吧!
另外用的時候要注意它是 binding `alt + ins` 要改的話可以看 [vsct](https://github.com/sergey-rybalkin/Emmet.net/blob/master/Emmet/EmmetPackage.vsct#L149) 檔最後幾行的 code
### code
```
        public override int Exec(
            ref Guid pguidCmdGroup, uint nCmdID, uint nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            if (PackageGuids.GuidEmmetPackageCmdSet != pguidCmdGroup ||
                PackageIds.CmdIDExpandMnemonic != nCmdID)
            {
                return base.Exec(ref pguidCmdGroup, nCmdID, nCmdexecopt, pvaIn, pvaOut);
            }

            // Get mnemonic content from editor.
            SnapshotPoint caretPosition = View.WpfView.Caret.Position.BufferPosition;
            ITextSnapshotLine line = View.WpfView.Caret.Position.BufferPosition.GetContainingLine();
            string lineText = line.GetText();

            string mnemonic = lineText.TrimStart();
            string indent = new string(' ', lineText.Length - mnemonic.Length);
            string snippet = string.Empty;
            int caretOffset = 0;
            bool isVar = lineText.EndsWith( ".var" );
            if (isVar)
            {
                caretOffset = snippet.Length + 5 - mnemonic.Length;
                snippet = "var x = ";
                snippet += mnemonic.Replace( ".var", ";" );
            }

            // Insert generated snippet into the current editor window
            int startPosition = line.End.Position - mnemonic.Length;
            Span targetPosition = new Span(startPosition, mnemonic.Length);
            View.CurrentBuffer.Replace(targetPosition, snippet);

            // Close all intellisense windows
            _completionBroker.DismissAllSessions(View.WpfView);

            // Move caret to the position where user can start typing new member name
            caretPosition = new SnapshotPoint(
                View.CurrentBuffer.CurrentSnapshot,
                caretPosition.Position + caretOffset);
            View.WpfView.Caret.MoveTo(caretPosition);

            return VSConstants.S_OK;
        }
```
### 後記
本來已經放棄得差不多了 , 結果在網路上發現了幾個線索 [Roslyn Cookbook](https://subscription.packtpub.com/book/application_development/9781787286832/3/ch03lvl1sec27/creating-a-completionprovider-to-provide-additional-intellisense-items-while-editing-code) [Roslyn Cookbook CompletionProvider](https://github.com/PacktPublishing/Roslyn-Cookbook/tree/master/Chapter03/CodeSamples/Recipe%205%20-%20CompletionProvider) [還有這個 OpenSource 專案](https://github.com/exyi/SampleCompletionProviders) 在一陣亂搞以後還真的寫出來第一個雛形 code 沒整理很醜就先不管了 , 萬一失去這筆記更是麻煩
注意要安裝這三個套件 `Microsoft.CodeAnalysis` `Microsoft.CodeAnalysis.Features` `Microsoft.VisualStudio.LanguageServices`
```
using System.Composition;
using Microsoft.CodeAnalysis;
using System.Threading;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Collections.Immutable;
using Microsoft.CodeAnalysis.Formatting;
using Microsoft.CodeAnalysis.Options;
using Microsoft.CodeAnalysis.Text;
using System.IO;
using Microsoft.VisualStudio.LanguageServices;
using System.Diagnostics;

namespace VSIXProjectMultiLang
{

    public static class CompletionHelpers
    {
        // unfortunately current node is not in the CompletionContext, we have to find it ourselves
        public static MemberAccessExpressionSyntax GetCurrentMemberAccess(this SyntaxNode node, int currentPosition)
        {
            var allNodes = node.DescendantNodes(n => n.FullSpan.Contains(currentPosition - 1)); // all nodes that contain currentPosition
            return allNodes.OfType<MemberAccessExpressionSyntax>().FirstOrDefault(m => m.OperatorToken.FullSpan.Contains(currentPosition - 1)) ?? // member access expression witch ends here
                allNodes.OfType<SimpleNameSyntax>().FirstOrDefault(m => m.Span.Contains(currentPosition - 1))?.Parent as MemberAccessExpressionSyntax; // or parent of identifier which contains currentPosition
        }

        public static T FixStatement<T>(this T statement)
            where T : StatementSyntax
        {
            // insert missing semicolon to the statement
            if (statement is ExpressionStatementSyntax)
            {
                var est = statement as ExpressionStatementSyntax;
                if (est.SemicolonToken.Span.Length == 0) return (T)(StatementSyntax)est.WithSemicolonToken(SyntaxFactory.Token(SyntaxKind.SemicolonToken));
            }
            return statement;
        }
    }




    [ExportCompletionProvider(name: nameof(CustomCompletionProvider), language: LanguageNames.CSharp), Shared]
    internal class CustomCompletionProvider : CompletionProvider
    {
        private const string Receiver = nameof(Receiver);
        private const string Description = nameof(Description);

        public override bool ShouldTriggerCompletion(SourceText text, int caretPosition, CompletionTrigger trigger, OptionSet options)
        {
            switch (trigger.Kind)
            {
                case CompletionTriggerKind.Insertion:
                    return ShouldTriggerCompletion(text, caretPosition);

                default:
                    return false;
            }
        }

        private static bool ShouldTriggerCompletion(SourceText text, int position)
        {
            // Provide completion if user typed "." after a whitespace/tab/newline char.
            var insertedCharacterPosition = position - 1;
            if (insertedCharacterPosition <= 0)
            {
                return false;
            }

            var ch = text[insertedCharacterPosition];
            var previousCh = text[insertedCharacterPosition - 1];
            return ch == '.' &&
                (char.IsWhiteSpace(previousCh) || previousCh == '\t' || previousCh == '\r' || previousCh == '\n');
        }
        public override async Task ProvideCompletionsAsync(CompletionContext context)
        {
            if (!context.Document.SupportsSemanticModel) return;

            var model = await context.Document.GetSemanticModelAsync();
            var treeRoot = await context.Document.GetSyntaxRootAsync();

            // find the current member access
            var node = treeRoot.GetCurrentMemberAccess(context.Position);
            if (node == null) return;
            var target = node.Expression;
            var targetType = model.GetTypeInfo(target).Type;
            Debug.WriteLine( targetType.Name );
            if (targetType == null) return;


            var item2 = CompletionItem.Create(
                "var",
               properties: ImmutableDictionary<string, string>.Empty
                .Add(Receiver, "var x = ")
                .Add(Description, $"var x = new {targetType.Name}()"));
            context.AddItem(item2);


            //foreach (var ss in snippets)
            //{
            //    if (ss.GetCompletion(context, target, targetType, model) is CompletionItem ci)
            //    {
            //        if (ci.Tags.Length == 0) ci = ci.AddTag("Snippet");
            //        context.AddItem(ci.AddProperty(CurrentSnipperProperty, ss.GetType().ToString()));
            //    }
            //}
        }

        public async  Task ProvideCompletionsAsync2(CompletionContext context)
        {
            var model = await context.Document.GetSemanticModelAsync(context.CancellationToken).ConfigureAwait(false);
            var text = await model.SyntaxTree.GetTextAsync(context.CancellationToken).ConfigureAwait(false);
            if (!ShouldTriggerCompletion(text, context.Position))
            {
                return;
            }


            var enclosingType = model.GetEnclosingSymbol( context.Position, context.CancellationToken ) as ITypeSymbol;
            if(enclosingType != null)
            {
                var typeToSuggest = GetAccessibleMembersInThisAndBaseTypes(
                    enclosingType.ContainingType,
                    enclosingType.IsStatic == false,
                    position: context.Position - 1,
                    model: model);
                foreach (var item in typeToSuggest)
                {
                    Debug.WriteLine( item );
                }
            }

            

            // Only provide completion in method body.
            var enclosingMethod = model.GetEnclosingSymbol(context.Position, context.CancellationToken) as IMethodSymbol;
            if (enclosingMethod == null)
            {
                return;
            }

            // Get all accessible members in this and base types.
            var membersToSuggest = GetAccessibleMembersInThisAndBaseTypes(
                enclosingMethod.ContainingType,
                isStatic: enclosingMethod.IsStatic,
                position: context.Position - 1,
                model: model);

            // Add completion for each member.
            int total = membersToSuggest.Count();
            int count = 1;
            foreach (var member in membersToSuggest)
            {
                // Ignore constructors
                if ((member as IMethodSymbol)?.MethodKind == MethodKind.Constructor)
                {
                    continue;
                }

                // Add receiver and description properties.
                var receiver = enclosingMethod.IsStatic ? member.ContainingType.ToDisplayString(SymbolDisplayFormat.MinimallyQualifiedFormat) : "this";
                var description = member.ToMinimalDisplayString(model, context.Position - 1);

                var properties = ImmutableDictionary<string, string>.Empty
                    .Add(Receiver, receiver)
                    .Add(Description, description);

                // Compute completion tags to display.
                var tags = GetCompletionTags(member).ToImmutableArray();
                // Add completion item.
                var item = CompletionItem.Create(member.Name, properties: properties, tags: tags);
                context.AddItem(item);

                if(count == total)
                {
                    var item2 = CompletionItem.Create(
                        "var",
                       properties: ImmutableDictionary<string, string>.Empty
                        .Add(Receiver, "var x = ")
                        .Add(Description, "var x = new Person()"));
                    context.AddItem(item2);
                }
                else
                {
                    count++;
                }
            }


        }

        private static ImmutableArray<ISymbol> GetAccessibleMembersInThisAndBaseTypes(ITypeSymbol containingType, bool isStatic, int position, SemanticModel model)
        {
            var types = GetBaseTypesAndThis(containingType);
            return types.SelectMany(x => x.GetMembers().Where(m => m.IsStatic == isStatic && model.IsAccessible(position, m)))
                        .ToImmutableArray();
        }

        private static IEnumerable<ITypeSymbol> GetBaseTypesAndThis(ITypeSymbol type)
        {
            var current = type;
            while (current != null)
            {
                yield return current;
                current = current.BaseType;
            }
        }

        public override Task<CompletionDescription> GetDescriptionAsync(Document document, CompletionItem item, CancellationToken cancellationToken)
        {
            return Task.FromResult(CompletionDescription.FromText(item.Properties[Description]));
        }


        public async  override Task<CompletionChange> GetChangeAsync(Document document, CompletionItem item, char? commitKey, CancellationToken cancellationToken)
        {
            // custom completion logic
            var model = await document.GetSemanticModelAsync();
            var tree = model.SyntaxTree;
            var root = await tree.GetRootAsync();

            var memberAccess = (await tree.GetRootAsync()).GetCurrentMemberAccess(item.Span.Start);
            var text = memberAccess.GetText();
            var tailText = text.ToString().Trim().TrimEnd( '.' );
            Debug.WriteLine(tailText);

            // Get new text replacement and span.
            var receiver = item.Properties[Receiver];
            var newText = $"{receiver}{tailText};";
            //var newSpan = new TextSpan( item.Span.Start - 1, 1 );
            var end = memberAccess.Span.End - memberAccess.Span.Start - 1;
            var newSpan = new TextSpan( memberAccess.Span.Start , end);

            //var receiver = item.Properties[Receiver];
            //var newText = $"{receiver}";
            //var newSpan = new TextSpan(memberAccess.Span.Start - 1, 1);

            // Return the completion change with the new text change.
            var 
```
### 參考資料
[可能還有希望搞出來的客製化 XAML intellisense](https://www.codeproject.com/Articles/1216579/Implementing-Custom-XAML-Intellisense-VS-Extension)
[線索1](http://blog.robertgreyling.com/2010/05/sparksense-getting-started-wheres.html)
[線索2](https://stackoverflow.com/questions/10460138/custom-intellisense-extension)
[微軟範例](https://docs.microsoft.com/en-us/visualstudio/extensibility/walkthrough-displaying-statement-completion?view=vs-2019)
[微軟範例中文](https://docs.microsoft.com/zh-tw/visualstudio/extensibility/walkthrough-displaying-statement-completion?view=vs-2019)
[一個顏色的 extension 作法說明](https://www.codeproject.com/Articles/1245021/Extending-Visual-Studio-to-Provide-a-Colorful-Lang)
[滿屌的老外解答線索](https://stackoverflow.com/questions/33461580/how-to-extend-the-information-that-provides-intellisense-using-the-visual-studio)
