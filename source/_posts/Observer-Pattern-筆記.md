---
title: Observer Pattern 筆記
date: 2023-06-26 18:35:20
tags:
- design pattern
- c#
---
&nbsp;
<!-- more -->

端午腦波一弱買個 [Android 的課來看看](https://www.udemy.com/course/android-dev-wilson/) , 結果一開始教 design pattern XD , 只好硬著頭皮跟著學
範例是用 java , 自己用 c# 改寫下

### 改寫 observer pattern 之前

動物的部分
這裡幾個問題點 , java 用 ImageIcon , 我 c# 想說用 Icon 可是 Icon 好像要真的是符合 ico 檔的大小才可以
所以用 `Bitmap` 就沒這個問題

```
    public interface Animal
    {
        void Draw(Graphics g);
        void Dance();
    }
    public class RedPanda : Animal
    {
        private Point point;
        private Bitmap redPanda = new Bitmap(@"Images\redpanda.png");

        public RedPanda(int x, int y)
        {

            point = new Point(x, y);
        }

        public virtual void Draw(Graphics g)
        {
            g.DrawImage(redPanda, point.X, point.Y);
        }

        public virtual void Dance()
        {
            Random random = new Random();
            int newX = (int)(random.NextDouble() * 10 - 5);
            int newY = (int)(random.NextDouble() * 10 - 5);
            point.X += newX;
            point.Y += newY;
        }
    }
    public class Dog : Animal
    {
        private Point point;
        private Bitmap dog = new Bitmap(@"Images\dog.png");

        public Dog(int x, int y)
        {

            point = new Point(x, y);
        }

        public virtual void Draw(Graphics g)
        {
            g.DrawImage(dog, point.X, point.Y);
        }

        public virtual void Dance()
        {
            Random random = new Random();
            int newX = (int)(random.NextDouble() * 10 - 5);
            int newY = (int)(random.NextDouble() * 10 - 5);
            point.X += newX;
            point.Y += newY;
        }
    }
```

winform 的部分
java 裡用的 `scheduleAtFixedRate` 在 c# 裡面比較相似的應該是 System.Threading.Timer
https://learn.microsoft.com/zh-tw/dotnet/api/system.threading.timer.-ctor?view=net-7.0#system-threading-timer-ctor(system-threading-timercallback-system-object-system-int32-system-int32)
他吃 4 個參數
* TimerCallback 委派 => 這個要寫個參數為 (object state) 的方法
* state => 這裡可以傳任何物件 , 一般會傳想要的資訊進去
* dueTime => 延遲時間
* period => 幾毫秒呼叫一次

他的範例用到 inner class , 我自己實戰沒怎用過 inner class , 而且 c# 的 inner class 好像沒辦法跟 java 一樣直接可以訪問 parent
所以在 TimerMission 的 Run 方法直接把 state 轉型為 parent , 或是直接在建構子傳入應該也可以
這裡只要呼叫 `Invalidate` 就會觸發 `OnPaint` 讓表單重新繪製

```
public class TimerMission
{
	private List<Animal> animals;
	public TimerMission(List<Animal> animals)
	{
		this.animals = animals;
	}

	public void Run(object state)
	{
		foreach (var animal in animals) animal.Dance();

		//把 parent 送進來並且強制轉型
		var parent = (Form1)state;

		//呼叫這句可以觸發 OnPaint
		parent.Invalidate();
	}
}


public partial class Form1 : Form
{
	private List<Animal> redPandas = new List<Animal>();
	private List<Animal> dogs = new List<Animal>();
	private System.Threading.Timer timer;
	private int speed = 100;

	protected override void OnPaint(PaintEventArgs e)
	{
		e.Graphics.Clear(Color.White);
		foreach (var redPanda in redPandas)
		{
			redPanda.Draw(e.Graphics);
		}

		foreach (var dog in dogs)
		{
			dog.Draw(e.Graphics);
		}
	}


	public Form1()
	{
		InitializeComponent();

		this.StartPosition = FormStartPosition.CenterScreen;
		this.Width = 500;
		this.Height = 500;
	}

	protected override void OnLoad(EventArgs e)
	{
		timer = new System.Threading.Timer(new TimerMission(this.redPandas).Run, this, 0, speed);
		timer = new System.Threading.Timer(new TimerMission(this.dogs).Run, this, 150, speed += 500);
		redPandas.Add(new RedPanda(30, 30));
		redPandas.Add(new RedPanda(230, 230));
		redPandas.Add(new RedPanda(90, 100));

		dogs.Add(new Dog(200, 100));
		dogs.Add(new Dog(300, 50));
		dogs.Add(new Dog(400, 400));
	}

}

```


### 套用 observer pattern 之後

動物部分
新增 `interface TickListener` , 並且註解 `Animal` , 改繼承 `TickListener`
實際上沒把 `Animal` 註解起來應該也可以 , 只不過在加入 `Register` 時要強制轉型為 `RedPanda` or `Dog`
```
    //Observer
    public interface TickListener
    {
        //notify
        public void Tick();
    }

    //public interface Animal
    //{
    //    void Draw(Graphics g);
    //    void Dance();
    //}

    public class RedPanda : TickListener
    {
        private Point point;
        private Bitmap redPanda = new Bitmap(@"Images\redpanda.png");

        public RedPanda(int x, int y)
        {

            point = new Point(x, y);
        }

        public virtual void Draw(Graphics g)
        {
            g.DrawImage(redPanda, point.X, point.Y);
        }

        public virtual void Dance()
        {
            Random random = new Random();
            int newX = (int)(random.NextDouble() * 10 - 5);
            int newY = (int)(random.NextDouble() * 10 - 5);
            point.X += newX;
            point.Y += newY;
        }

        public void Tick()
        {
            this.Dance();
        }
    }
    public class Dog : TickListener
    {
        private Point point;
        private Bitmap dog = new Bitmap(@"Images\dog.png");

        public Dog(int x, int y)
        {

            point = new Point(x, y);
        }

        public virtual void Draw(Graphics g)
        {
            g.DrawImage(dog, point.X, point.Y);
        }

        public virtual void Dance()
        {
            Random random = new Random();
            int newX = (int)(random.NextDouble() * 10 - 5);
            int newY = (int)(random.NextDouble() * 10 - 5);
            point.X += newX;
            point.Y += newY;
        }

        public void Tick()
        {
            this.Dance();
        }
    }
```

subject 部分
```
//subject
public class TimerMission
{
	private List<TickListener> listeners = new List<TickListener>();

	//add observer
	public void Register(TickListener listener)
	{
		this.listeners.Add(listener);
	}

	//remove observer
	public void Unregister(TickListener listener)
	{
		this.listeners.Remove(listener);
	}

	//notify observers
	public void Run(object state)
	{
		foreach (var listener in listeners)
		{
			listener.Tick();
		}
	}
}

```

winform 部分

也讓表單繼承 `TickListener` 然後實作 `Tick` 讓他重新繪製

```
public partial class Form1 : Form, TickListener
{
	private List<RedPanda> redPandas = new List<RedPanda>();
	private List<Dog> dogs = new List<Dog>();
	private System.Threading.Timer timer;
	private int speed = 100;
	private TimerMission tm1 = new TimerMission();
	private TimerMission tm2 = new TimerMission();

	protected override void OnPaint(PaintEventArgs e)
	{
		e.Graphics.Clear(Color.White);
		foreach (var redPanda in redPandas)
		{
			redPanda.Draw(e.Graphics);
		}

		foreach (var dog in dogs)
		{
			dog.Draw(e.Graphics);
		}
	}


	public Form1()
	{
		InitializeComponent();

		this.StartPosition = FormStartPosition.CenterScreen;
		this.Width = 500;
		this.Height = 500;
	}

	protected override void OnLoad(EventArgs e)
	{
		timer = new System.Threading.Timer(tm1.Run, this, 0, speed);
		timer = new System.Threading.Timer(tm2.Run, this, 150, speed += 500);
		redPandas.Add(new RedPanda(30, 30));
		redPandas.Add(new RedPanda(230, 230));
		redPandas.Add(new RedPanda(90, 100));
		foreach (var redPanda in this.redPandas)
		{
			tm1.Register(redPanda);
		}
		tm1.Register(this);

		dogs.Add(new Dog(200, 100));
		dogs.Add(new Dog(300, 50));
		dogs.Add(new Dog(400, 400));
		foreach (var dog in dogs)
		{
			tm2.Register(dog);
		}
		tm2.Register(this);
	}

	public void Tick()
	{
		this.Invalidate();
	}
}

```
