---
title: visual studio 製作多語系 extension
date: 2021-01-31 23:20:07
tags:
- visual studio
- 外掛
- extension
---
&nbsp;
<!-- more -->

由於專案有太多莫名其妙的多語系變數，看得是眼花撩亂，上網又沒找到類似套件，所以決定自己寫一個，最主要是參考自[C# Var Type CodeLens](https://marketplace.visualstudio.com/items?itemName=AlexanderGayko.VarAdorner)
由於他沒有提供程式碼所以先安裝[dotPeek](https://www.jetbrains.com/decompiler/download/#section=web-installer)進行反組譯來參考程式碼
最關鍵點就在 SpaceNegotiatingAdornmentTag 這個類別，看起來是拿來補充行距的，不然直接把文字畫在 editor 上面會擋住程式碼，顯示多語系 value 的邏輯只寫一半有點 bug
### 關鍵一
``` csharp
    internal class MultiLangTag : SpaceNegotiatingAdornmentTag
    {
        public MultiLangTag(double width, double topSpace, double baseline, double textHeight, double bottomSpace, Microsoft.VisualStudio.Text.PositionAffinity affinity, object identityTag, object providerTag) : base( width, topSpace, baseline, textHeight, bottomSpace, affinity, identityTag, providerTag )
        {
        }
    }
    internal sealed class MultiLangTagger : ITagger<MultiLangTag>
    {
        public MultiLangTagger()
        {
        }
        public event EventHandler<SnapshotSpanEventArgs> TagsChanged;

        public IEnumerable<ITagSpan<MultiLangTag>> GetTags(NormalizedSnapshotSpanCollection spans)
        {
            if (MyConfig.IsEnable == true)
            {
                foreach (var span in spans)
                {
                    var currentLineText = span.GetText( );
                    int find = -1;
                    bool isFind = false;
                    string strTranslate = "";
                    foreach (var item in MyConfig.Dict.Keys)
                    {
                        isFind = currentLineText.IndexOf( item ) > 0;
                        if (isFind)
                        {
                            find = currentLineText.IndexOf( item );
                            strTranslate = MyConfig.Dict[item];
                            break;
                        };
                    }

                    if (find > -1)
                    {
						//關鍵
                        yield return (ITagSpan<MultiLangTag>)new TagSpan<MultiLangTag>(
                            new SnapshotSpan( span.Snapshot.TextBuffer.CurrentSnapshot, (Span)span ),
                            //1.2是邊距
                            new MultiLangTag( 0.0, (double)MyConfig.FontSize * 1.2, 0.0, 0.0, 0.0, PositionAffinity.Predecessor, (object)null, (object)null ) );
                    }
                }

            }
        }
    }

```

### 關鍵二
接著第二個關鍵點就是 CreateVisuals 這裡面的邏輯，目前開發一半是判斷找到第一個字以後就把多語系的值給顯示在上面
主要是賽入一個 TextBlock 控制項? 沒怎麼寫過 wpf 忘光光 , 接著在 Canvas.SetLeft 跟 Canvas.SetTop 上面進行繪製位置的計算，想要擺哪邊可以自己視情況調整，基本上就搞定了 , 等整個寫完再放到 github 上吧..
``` csharp
        private void DrawLang(IWpfTextViewLineCollection textViewLines, SnapshotSpan span , string text)
        {
            Geometry geometry = textViewLines.GetMarkerGeometry( span );
            if (geometry != null)
            {
                var brush = new SolidColorBrush( MyConfig.Color );

                var textBlock = new TextBlock
                {
                    Text = text,
                    Foreground = brush,
                    FontSize = MyConfig.FontSize 
                };

                // Align the image with the top of the bounds of the text geometry
                Canvas.SetLeft( textBlock, geometry.Bounds.Left );
                Canvas.SetTop( textBlock, geometry.Bounds.Top - MyConfig.FontSize );

                this.layer.AddAdornment( AdornmentPositioningBehavior.TextRelative, span, null, textBlock, null );
            }
        }

```
