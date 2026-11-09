# Generates 10 unique OOP model papers (HTML) then prints PDF via Chrome.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$css = Get-Content (Join-Path $root '_shared-style.css') -Raw

function Html-Escape([string]$s) {
  if ($null -eq $s) { return '' }
  return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;')
}

function New-PaperHtml {
  param(
    [int]$Num,
    [string]$Difficulty,
    [string]$DiffClass,
    [string]$Focus,
    [array]$Questions
  )

  $qHtml = foreach ($q in $Questions) {
    $parts = ""
    if ($q.Code) {
      $parts += "<div class=`"code`">$(($q.Code -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'))</div>`n"
    }
    if ($q.Intro) {
      $parts += "<p>$($q.Intro)</p>`n"
    }
    $parts += "<ol type=`"a`">`n"
    foreach ($item in $q.Items) {
      $parts += "  <li>$item</li>`n"
    }
    $parts += "</ol>`n"
    @"
  <div class="q">
    <div class="q-head">Question $($q.N) &nbsp;[20 Marks]</div>
    $parts
  </div>
"@
  }

  @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Model Paper $('{0:D2}' -f $Num) - OOP - $Difficulty</title>
  <style>
$css
  </style>
</head>
<body>
  <div class="header">
    <div class="inst">College of Technology Galle</div>
    <div class="mod">Course: Full Stack Software Development &mdash; Object Oriented Programming &mdash; Module K72T004M03 &mdash; NVQ Level 05</div>
    <div class="paper-title">Semester Model Paper $($Num.ToString('00'))</div>
    <div class="sub">Focus: $Focus</div>
    <div class="diff $DiffClass">Difficulty: $Difficulty</div>
  </div>

  <div class="info">
    <div><strong>Duration:</strong> 3 Hours</div>
    <div><strong>Total Marks:</strong> 100</div>
    <div><strong>Questions:</strong> 7 structured questions (answer any <strong>5</strong>)</div>
    <div><strong>Each question:</strong> 20 marks</div>
  </div>

  <div class="box">
    <h3>Instructions to Candidates</h3>
    <ol>
      <li>Answer any <strong>five (5)</strong> questions out of the seven provided.</li>
      <li>Each question carries <strong>20 marks</strong>. Maximum mark for this paper is <strong>100</strong>.</li>
      <li>Write answers in the answer booklet. Do <strong>not</strong> write answers on this question paper.</li>
      <li>Where Java code is required, write clear, syntactically correct Java as taught in this module (VS Code / JDK).</li>
      <li>Show workings / short explanations where asked. Manage your time (about 35 minutes per question).</li>
      <li>Mobile phones and programmable devices are not allowed.</li>
    </ol>
  </div>

$($qHtml -join "`n")

  <div class="end">***** END OF QUESTION PAPER *****</div>
  <div class="footer">
    College of Technology Galle &nbsp;|&nbsp; OOP Module K72T004M03 &nbsp;|&nbsp; Model Paper $($Num.ToString('00')) ($Difficulty)
  </div>
</body>
</html>
"@
}

# ========== 10 PAPERS × 7 UNIQUE QUESTIONS ==========
$papers = @(
  @{
    Num=1; Difficulty='Easy'; DiffClass='diff-easy'; Focus='Basic Java, variables, decisions, simple methods &amp; classes'
    Questions=@(
      @{ N=1; Intro='This question covers JDK tools and the structure of a simple Java program.'; Items=@(
        'What do the abbreviations <strong>JDK</strong> and <strong>JVM</strong> stand for? State one role of each. <strong>(6 marks)</strong>'
        'Name the IDE allowed in this module and the extension pack needed for Java. <strong>(4 marks)</strong>'
        'Write the two terminal commands to compile and run a file named <code>Hello.java</code> (class <code>Hello</code>). <strong>(4 marks)</strong>'
        'Why must the <code>main</code> method be present in a console application? <strong>(6 marks)</strong>'
      )}
      @{ N=2; Intro='Data types and console output.'; Items=@(
        'List five primitive Java types used in this module and give one example value for each. <strong>(5 marks)</strong>'
        'Write declarations (with initial values) for: student name, age, course fee, paid status, and grade letter. <strong>(5 marks)</strong>'
        'Write one <code>System.out.println</code> statement that prints: <em>Hello Amal, age 21</em> using variables <code>name</code> and <code>age</code>. <strong>(4 marks)</strong>'
        'Explain the difference between <code>String</code> quotes and <code>char</code> quotes with one example each. <strong>(6 marks)</strong>'
      )}
      @{ N=3; Code=@'
int marks = 65;
if (marks >= 50) {
    System.out.println("Pass");
} else {
    System.out.println("Fail");
}
'@; Intro='Study the decision structure below.'; Items=@(
        'What is printed when <code>marks</code> is 65? What is printed when <code>marks</code> is 40? <strong>(4 marks)</strong>'
        'Rewrite the program using an <code>if / else if / else</code> chain that prints Distinction (>=75), Credit (65-74), Pass (50-64), or Fail. <strong>(10 marks)</strong>'
        'Explain in one sentence when the <code>else</code> block runs. <strong>(6 marks)</strong>'
      )}
      @{ N=4; Intro='Loops - basics.'; Items=@(
        'Write a <code>for</code> loop that prints the numbers 1 to 5 (each on a new line). <strong>(6 marks)</strong>'
        'Write a <code>while</code> loop that prints "Hello" exactly three times. <strong>(6 marks)</strong>'
        'State one difference between <code>while</code> and <code>do-while</code>. <strong>(4 marks)</strong>'
        'Why can an infinite loop be a problem in a console menu? <strong>(4 marks)</strong>'
      )}
      @{ N=5; Intro='Methods - simple reuse.'; Items=@(
        'What does the keyword <code>void</code> mean in a method header? <strong>(4 marks)</strong>'
        'Write a method <code>public static void greet(String name)</code> that prints <em>Welcome, &lt;name&gt;</em>. <strong>(6 marks)</strong>'
        'Write a method <code>public static int square(int n)</code> that returns <code>n * n</code>. Show one call from <code>main</code>. <strong>(6 marks)</strong>'
        'Explain the difference between a parameter and an argument. <strong>(4 marks)</strong>'
      )}
      @{ N=6; Intro='Classes and objects - first look.'; Items=@(
        'In one sentence each, define <strong>class</strong> and <strong>object</strong>. <strong>(6 marks)</strong>'
        'Write a class <code>Book</code> with two public fields: <code>title</code> (String) and <code>pages</code> (int). <strong>(6 marks)</strong>'
        'In <code>main</code>, create one <code>Book</code> object, set both fields, and print them. <strong>(6 marks)</strong>'
        'Why can many objects be created from the same class? <strong>(2 marks)</strong>'
      )}
      @{ N=7; Intro='Encapsulation - introductory idea.'; Items=@(
        'What does encapsulation mean in simple words? Give one real-world analogy (e.g. ATM). <strong>(6 marks)</strong>'
        'Why is a public <code>balance</code> field dangerous in a bank account class? <strong>(6 marks)</strong>'
        'Write a private field <code>balance</code> and a public method <code>getBalance()</code> that returns it. <strong>(6 marks)</strong>'
        'What access modifier means "visible only inside the same class"? <strong>(2 marks)</strong>'
      )}
    )
  }

  @{
    Num=2; Difficulty='Easy'; DiffClass='diff-easy'; Focus='Scanner I/O, operators, methods, fields, getters/setters intro'
    Questions=@(
      @{ N=1; Intro='Console input with Scanner.'; Items=@(
        'Write the import and the line that creates a <code>Scanner</code> reading from <code>System.in</code>. <strong>(4 marks)</strong>'
        'Write code that asks for a student's name and age, reads both, and prints them. <strong>(8 marks)</strong>'
        'Which method reads a whole line of text? Which is commonly used for an <code>int</code>? <strong>(4 marks)</strong>'
        'What problem can occur if the user types letters when an integer is expected? (Name the issue in plain words.) <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Operators and expressions.'; Items=@(
        'Evaluate: <code>10 + 3 * 2</code> and <code>(10 + 3) * 2</code>. Show working. <strong>(4 marks)</strong>'
        'Write a boolean expression that is true when <code>age</code> is at least 18 and <code>hasId</code> is true. <strong>(4 marks)</strong>'
        'Explain the difference between <code>=</code> and <code>==</code> with a tiny example. <strong>(6 marks)</strong>'
        'What does the modulus operator <code>%</code> return? Give one example. <strong>(6 marks)</strong>'
      )}
      @{ N=3; Code=@'
public static int add(int a, int b) {
    return a + b;
}
'@; Intro='Study the method.'; Items=@(
        'What are the return type and the two parameters? <strong>(4 marks)</strong>'
        'Write a complete <code>main</code> that calls <code>add(7, 5)</code> and prints the result. <strong>(6 marks)</strong>'
        'Rewrite the method as <code>void</code> so it prints the sum instead of returning it. <strong>(6 marks)</strong>'
        'Can a <code>void</code> method use <code>return 5;</code>? Explain briefly. <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='Fields vs local variables (simple).'; Items=@(
        'Where is a field declared? Where is a local variable declared? <strong>(6 marks)</strong>'
        'Write a class <code>Lamp</code> with a field <code>boolean isOn</code> and methods <code>turnOn()</code> / <code>turnOff()</code> that change it. <strong>(8 marks)</strong>'
        'Explain why a local variable declared inside <code>turnOn</code> cannot be used inside <code>turnOff</code>. <strong>(6 marks)</strong>'
      )}
      @{ N=5; Intro='Getters and setters - first practice.'; Items=@(
        'What is a getter used for? What is a setter used for? <strong>(4 marks)</strong>'
        'For a private field <code>String title</code>, write <code>getTitle</code> and <code>setTitle</code>. <strong>(8 marks)</strong>'
        'Improve <code>setTitle</code> so it rejects an empty string (print a message and keep the old value). <strong>(6 marks)</strong>'
        'State the usual JavaBeans name for a getter of field <code>author</code>. <strong>(2 marks)</strong>'
      )}
      @{ N=6; Intro='Procedural vs OOP (simple comparison).'; Items=@(
        'Describe procedural programming in two sentences. <strong>(4 marks)</strong>'
        'Describe object-oriented programming in two sentences. <strong>(4 marks)</strong>'
        'Name the four pillars of OOP. <strong>(4 marks)</strong>'
        'Give one advantage of modelling a library with <code>Book</code> objects instead of only separate variables in <code>main</code>. <strong>(8 marks)</strong>'
      )}
      @{ N=7; Intro='Simple class design.'; Items=@(
        'Using the noun/verb idea, list two fields and two methods for a <code>Student</code> class. <strong>(6 marks)</strong>'
        'Write the Java class with those private fields and public methods (stubs are enough for methods that only print). <strong>(10 marks)</strong>'
        'In <code>main</code>, create two different <code>Student</code> objects to show that each has its own data. <strong>(4 marks)</strong>'
      )}
    )
  }

  @{
    Num=3; Difficulty='Easy-Moderate'; DiffClass='diff-easy-mod'; Focus='Classes, encapsulation, constructors intro, simple validation'
    Questions=@(
      @{ N=1; Intro='Class anatomy.'; Items=@(
        'Label each of the following as field, method, or neither: <code>speed</code>, <code>accelerate()</code>, <code>package</code>, <code>brand</code>. <strong>(4 marks)</strong>'
        'Write a <code>Vehicle</code> class with fields <code>brand</code> and <code>speed</code>, plus methods <code>accelerate()</code> (adds 10 to speed) and <code>display()</code>. <strong>(10 marks)</strong>'
        'Create two vehicles in <code>main</code> with different brands and show their speeds after one accelerate each. <strong>(6 marks)</strong>'
      )}
      @{ N=2; Intro='Access modifiers.'; Items=@(
        'Explain <code>public</code> vs <code>private</code> with one example each. <strong>(6 marks)</strong>'
        'What compile-time problem occurs if <code>main</code> tries to write to a private field directly? <strong>(4 marks)</strong>'
        'Refactor a public field <code>balance</code> into private + getter + deposit method with a positive-amount check. <strong>(10 marks)</strong>'
      )}
      @{ N=3; Code=@'
public class BankAccount {
    private double balance;
    public void deposit(double amount) {
        if (amount > 0) balance += amount;
    }
}
'@; Intro='Study the fragment.'; Items=@(
        'Why can <code>deposit</code> change <code>balance</code> even though the field is private? <strong>(4 marks)</strong>'
        'Add <code>withdraw(double amount)</code> that refuses negative amounts and amounts greater than balance. <strong>(8 marks)</strong>'
        'Add <code>getBalance()</code> and show three calls from <code>main</code>: deposit, withdraw, print. <strong>(8 marks)</strong>'
      )}
      @{ N=4; Intro='Constructors - introduction.'; Items=@(
        'What is a constructor? How does its name relate to the class name? <strong>(4 marks)</strong>'
        'Does a constructor have a return type (including <code>void</code>)? Explain. <strong>(4 marks)</strong>'
        'Write a default constructor and a parameterized constructor for class <code>Product</code> with fields <code>name</code> and <code>price</code>. <strong>(8 marks)</strong>'
        'When does a constructor run? <strong>(4 marks)</strong>'
      )}
      @{ N=5; Intro='The keyword <code>this</code> (simple).'; Items=@(
        'What does <code>this</code> refer to inside an instance method? <strong>(4 marks)</strong>'
        'Write <code>setPrice(double price) { this.price = price; }</code> and explain each <code>price</code>. <strong>(8 marks)</strong>'
        'What problem appears if you write <code>price = price;</code> inside that setter? <strong>(4 marks)</strong>'
        'Give one other situation where <code>this</code> is useful. <strong>(4 marks)</strong>'
      )}
      @{ N=6; Intro='Rectangle: procedural vs object (bridge).'; Items=@(
        'Describe how a procedural Rectangle program stores width and height. <strong>(4 marks)</strong>'
        'Write an OO <code>Rectangle</code> with private fields, a constructor, <code>area()</code>, and <code>perimeter()</code>. <strong>(10 marks)</strong>'
        'State two benefits of the OO version for a program that needs many rectangles. <strong>(6 marks)</strong>'
      )}
      @{ N=7; Intro='Library Phase 1 style - Book.'; Items=@(
        'List suitable fields for a library <code>Book</code> (at least four). <strong>(4 marks)</strong>'
        'Write <code>borrow()</code> and <code>returnBook()</code> methods that prevent double-borrow / double-return using a boolean flag. <strong>(10 marks)</strong>'
        'Explain why availability should not be set freely from outside without rules. <strong>(6 marks)</strong>'
      )}
    )
  }

  @{
    Num=4; Difficulty='Easy-Moderate'; DiffClass='diff-easy-mod'; Focus='Encapsulation practice, overloading intro, memory basics, inheritance vocab'
    Questions=@(
      @{ N=1; Intro='Design rule: hide data.'; Items=@(
        'State the usual rule for fields vs methods regarding <code>public</code>/<code>private</code>. <strong>(4 marks)</strong>'
        'Write an encapsulated <code>Employee</code> with private <code>name</code> and <code>salary</code>, getters, and a setter for salary that rejects values below 0. <strong>(10 marks)</strong>'
        'Show illegal vs legal access from <code>main</code> (one illegal line commented with the reason). <strong>(6 marks)</strong>'
      )}
      @{ N=2; Intro='Method overloading (same name, different parameters).'; Items=@(
        'What is method overloading? <strong>(4 marks)</strong>'
        'Write three overloaded <code>print</code> methods: one for <code>int</code>, one for <code>String</code>, one for <code>int</code> and <code>String</code>. <strong>(9 marks)</strong>'
        'How does Java decide which overloaded method to call? <strong>(4 marks)</strong>'
        'Can two methods overload if they differ only by return type? Explain. <strong>(3 marks)</strong>'
      )}
      @{ N=3; Intro='Constructor overloading.'; Items=@(
        'Write class <code>Member</code> with fields <code>id</code> and <code>name</code>, a no-arg constructor (default values), and a two-arg constructor. <strong>(10 marks)</strong>'
        'In <code>main</code>, create one object with each constructor and print their data. <strong>(6 marks)</strong>'
        'What does Java provide if you write no constructor at all? <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='Stack vs heap (simple memory).'; Items=@(
        'In simple words, what lives on the stack and what lives on the heap? <strong>(6 marks)</strong>'
        'Explain why <code>Book a = b;</code> can make two variables affect the same book. <strong>(8 marks)</strong>'
        'What does <code>null</code> mean? What exception appears if you call a method on <code>null</code>? <strong>(6 marks)</strong>'
      )}
      @{ N=5; Intro='Inheritance vocabulary.'; Items=@(
        'Define inheritance and the is-a relationship with one example (e.g. Car / Vehicle). <strong>(6 marks)</strong>'
        'Which keyword creates an inheritance link in Java? Write one class header example. <strong>(4 marks)</strong>'
        'Who is the superclass and who is the subclass in <code>class Dog extends Animal</code>? <strong>(4 marks)</strong>'
        'Can a subclass use private fields of the superclass directly? How should it access them? <strong>(6 marks)</strong>'
      )}
      @{ N=6; Intro='Variable scope (simplified).'; Items=@(
        'Define scope in one sentence. <strong>(3 marks)</strong>'
        'Classify <code>count</code> (field), <code>value</code> (parameter), and <code>next</code> (declared inside a method) by scope. <strong>(6 marks)</strong>'
        'Why does a variable declared inside an <code>if</code> block fail to compile if used after the block? <strong>(5 marks)</strong>'
        'Write a tiny example that needs <code>this.x = x;</code> and explain why. <strong>(6 marks)</strong>'
      )}
      @{ N=7; Intro='Short code reading.'; Code=@'
class Counter {
    private int n;
    public void bump() { n = n + 1; }
    public int getN() { return n; }
}
// main:
Counter c = new Counter();
c.bump(); c.bump();
System.out.println(c.getN());
'@; Items=@(
        'What is printed? Explain step by step. <strong>(6 marks)</strong>'
        'Is <code>n</code> a field or a local variable? How do you know? <strong>(4 marks)</strong>'
        'Add a constructor that sets <code>n</code> to a starting value supplied by the caller. <strong>(6 marks)</strong>'
        'What happens if <code>main</code> tries <code>c.n = 100;</code>? <strong>(4 marks)</strong>'
      )}
    )
  }

  @{
    Num=5; Difficulty='Moderate'; DiffClass='diff-mod'; Focus='Inheritance, super, protected, polymorphism intro'
    Questions=@(
      @{ N=1; Intro='Building an inheritance tree.'; Items=@(
        'Write class <code>Person</code> with private <code>name</code>, a constructor, and <code>getName()</code>. <strong>(6 marks)</strong>'
        'Write class <code>Teacher extends Person</code> with private <code>subject</code>, constructor calling <code>super</code>, and <code>display()</code>. <strong>(10 marks)</strong>'
        'Explain what <code>super(name)</code> does in the subclass constructor. <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Protected access.'; Items=@(
        'How does <code>protected</code> differ from <code>private</code> and <code>public</code>? <strong>(6 marks)</strong>'
        'Give a short example where a subclass method reads a protected superclass field. <strong>(8 marks)</strong>'
        'When would you still prefer private fields + getters over protected fields? <strong>(6 marks)</strong>'
      )}
      @{ N=3; Intro='Method overriding.'; Items=@(
        'What is overriding? How is it different from overloading? <strong>(6 marks)</strong>'
        'Write superclass method <code>speak()</code> and a subclass override that prints a different message. Include <code>@Override</code>. <strong>(8 marks)</strong>'
        'What is printed by <code>Animal a = new Dog(); a.speak();</code> if <code>Dog</code> overrides <code>speak</code>? Why? <strong>(6 marks)</strong>'
      )}
      @{ N=4; Intro='Polymorphism - first ideas.'; Items=@(
        'Define polymorphism in the context of OOP. <strong>(4 marks)</strong>'
        'Explain why a list of <code>Vehicle</code> references can hold <code>Car</code> and <code>Bike</code> objects. <strong>(6 marks)</strong>'
        'Write a small demo: array or list of superclass type, two subclasses, loop calling an overridden method. <strong>(10 marks)</strong>'
      )}
      @{ N=5; Code=@'
class Shape {
    public double area() { return 0; }
}
class Circle extends Shape {
    private double r;
    public Circle(double r) { this.r = r; }
    public double area() { return 3.14 * r * r; }
}
'@; Intro='Study the code.'; Items=@(
        'Identify the superclass, subclass, and overridden method. <strong>(6 marks)</strong>'
        'What does <code>Shape s = new Circle(2); System.out.println(s.area());</code> print (approx)? <strong>(4 marks)</strong>'
        'Rewrite <code>Shape.area</code> as <code>abstract</code> and make <code>Shape</code> an abstract class. Adjust <code>Circle</code> if needed. <strong>(10 marks)</strong>'
      )}
      @{ N=6; Intro='Library Phase 4/5 style thinking.'; Items=@(
        'Suggest a superclass for different library items (book, DVD) and two subclasses with one extra field each. <strong>(8 marks)</strong>'
        'Which behaviours belong in the superclass and which in subclasses? Justify briefly. <strong>(6 marks)</strong>'
        'How does inheritance reduce duplicated code in borrow/return logic? <strong>(6 marks)</strong>'
      )}
      @{ N=7; Intro='Exceptions - awareness (additional topic).'; Items=@(
        'What is an exception? What happens if it is not caught? <strong>(4 marks)</strong>'
        'Write a <code>try/catch</code> around <code>Integer.parseInt</code> that prints a friendly message on failure. <strong>(8 marks)</strong>'
        'Name three common exception types and one cause for each. <strong>(6 marks)</strong>'
        'Why is checking <code>if (obj != null)</code> often better than catching <code>NullPointerException</code>? <strong>(2 marks)</strong>'
      )}
    )
  }

  @{
    Num=6; Difficulty='Moderate'; DiffClass='diff-mod'; Focus='Abstraction, interfaces, object relationships intro'
    Questions=@(
      @{ N=1; Intro='Abstract classes.'; Items=@(
        'What is an abstract class? Can you write <code>new AbstractType()</code> if the type is abstract? <strong>(6 marks)</strong>'
        'Write abstract class <code>Employee</code> with an abstract method <code>pay()</code> and a concrete method <code>getName()</code>. <strong>(8 marks)</strong>'
        'Write one concrete subclass that implements <code>pay()</code>. <strong>(6 marks)</strong>'
      )}
      @{ N=2; Intro='Interfaces.'; Items=@(
        'What is an interface in Java? How does a class use one? <strong>(6 marks)</strong>'
        'Write interface <code>Payable</code> with method <code>double amountDue()</code> and a class that implements it. <strong>(8 marks)</strong>'
        'State two differences between an abstract class and an interface (as taught for this level). <strong>(6 marks)</strong>'
      )}
      @{ N=3; Intro='Association, aggregation, composition - concepts.'; Items=@(
        'Explain association (uses-a) with a short Java-flavoured example. <strong>(6 marks)</strong>'
        'Explain aggregation (has-a, shared lifetime) vs composition (part-of, strong ownership) with school/classroom examples. <strong>(10 marks)</strong>'
        'Why does composition often create the part objects inside the whole's constructor? <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='School project style.'; Items=@(
        'Design classes <code>Teacher</code> and <code>Classroom</code> showing a clear relationship (state which relationship you chose). <strong>(6 marks)</strong>'
        'Write Java outlines (fields + constructors + one method each) for your design. <strong>(10 marks)</strong>'
        'How would you print all students in a classroom if the classroom aggregates a list of students? <strong>(4 marks)</strong>'
      )}
      @{ N=5; Intro='Combining encapsulation + inheritance.'; Items=@(
        'Write <code>Account</code> with private balance, protected deposit helper or public deposit, and abstract <code>calcInterest()</code>. <strong>(10 marks)</strong>'
        'Write <code>SavingsAccount</code> that extends it and implements interest calculation. <strong>(6 marks)</strong>'
        'Explain how encapsulation still protects balance while inheritance reuses behaviour. <strong>(4 marks)</strong>'
      )}
      @{ N=6; Code=@'
interface Notifier {
    void send(String msg);
}
class EmailNotifier implements Notifier {
    public void send(String msg) { System.out.println("EMAIL: " + msg); }
}
'@; Intro='Study the interface example.'; Items=@(
        'What must every implementing class provide? <strong>(4 marks)</strong>'
        'Write a <code>SmsNotifier</code> implementation. <strong>(6 marks)</strong>'
        'Write a method <code>alert(Notifier n, String m)</code> that calls <code>n.send(m)</code>, and show calls with both implementations. <strong>(10 marks)</strong>'
      )}
      @{ N=7; Intro='Garbage collection &amp; lifecycle (link to memory lesson).'; Items=@(
        'Describe birth, life, and abandonment of an object in heap terms. <strong>(6 marks)</strong>'
        'What is the Garbage Collector's job? Do you call <code>delete</code> in Java? <strong>(6 marks)</strong>'
        'Show code that makes an object unreachable (e.g. assign <code>null</code> or reassign the only reference). <strong>(4 marks)</strong>'
        'Why can large temporary objects in a loop cause memory pressure even with GC? <strong>(4 marks)</strong>'
      )}
    )
  }

  @{
    Num=7; Difficulty='Moderate-Hard'; DiffClass='diff-mod-hard'; Focus='Integrated class design, polymorphism, validation &amp; exceptions'
    Questions=@(
      @{ N=1; Intro='Design a mini inventory.'; Items=@(
        'Specify fields and methods for <code>Item</code> (code, name, qty) with encapsulation rules. <strong>(6 marks)</strong>'
        'Implement the class with constructor, getters, <code>restock</code>, and <code>issue</code> (issue must not make qty negative). <strong>(10 marks)</strong>'
        'Explain how you would unit-test <code>issue</code> manually from <code>main</code> with two scenarios. <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Inheritance + overriding under rules.'; Items=@(
        'Create <code>Ticket</code> with method <code>price()</code> returning a base amount. <strong>(4 marks)</strong>'
        'Create <code>StudentTicket</code> and <code>VipTicket</code> with different price rules via override. <strong>(10 marks)</strong>'
        'Demonstrate polymorphic pricing in a loop over a <code>Ticket[]</code>. <strong>(6 marks)</strong>'
      )}
      @{ N=3; Intro='throw for domain rules.'; Items=@(
        'Rewrite a setter or withdraw method so invalid input throws <code>IllegalArgumentException</code>. <strong>(8 marks)</strong>'
        'Catch the exception in <code>main</code> and keep a menu running. <strong>(8 marks)</strong>'
        'Compare throwing vs printing an error message inside the class - when is throwing better? <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='Trace and fix.'; Code=@'
class Node {
    int value;
    Node next;
}
public class Trace {
    public static void main(String[] args) {
        Node a = new Node();
        a.value = 1;
        Node b = a;
        b.value = 2;
        System.out.println(a.value);
        b = new Node();
        b.value = 3;
        System.out.println(a.value);
    }
}
'@; Items=@(
        'What is printed by each <code>println</code>? Explain with stack/heap reasoning. <strong>(10 marks)</strong>'
        'Draw (or describe) references after <code>b = new Node()</code>. <strong>(6 marks)</strong>'
        'What would <code>a.next.value</code> do if <code>a.next</code> was never set? <strong>(4 marks)</strong>'
      )}
      @{ N=5; Intro='Abstract reporting.'; Items=@(
        'Design abstract <code>Report</code> with abstract <code>generate()</code> and concrete <code>header()</code>. <strong>(8 marks)</strong>'
        'Implement <code>SalesReport</code> and <code>AttendanceReport</code>. <strong>(8 marks)</strong>'
        'Show how a method can accept <code>Report r</code> and call <code>generate</code> without knowing the concrete type. <strong>(4 marks)</strong>'
      )}
      @{ N=6; Intro='Composition deep dive.'; Items=@(
        'Model a <code>Computer</code> composed of <code>Cpu</code> and <code>Memory</code> (composition). Write constructors that create the parts inside <code>Computer</code>. <strong>(10 marks)</strong>'
        'Explain why deleting/losing the <code>Computer</code> reference means the parts are no longer needed by the program. <strong>(4 marks)</strong>'
        'How would the design change if <code>Memory</code> could be swapped and reused in another computer (aggregation)? <strong>(6 marks)</strong>'
      )}
      @{ N=7; Intro='Safe console menu (integration).'; Items=@(
        'Write a helper <code>readInt(Scanner sc)</code> that loops until a valid integer is entered (use try/catch). <strong>(8 marks)</strong>'
        'Build a 3-option menu that uses the helper and exits cleanly on option 0. <strong>(8 marks)</strong>'
        'State two user mistakes your menu now survives. <strong>(4 marks)</strong>'
      )}
    )
  }

  @{
    Num=8; Difficulty='Moderate-Hard'; DiffClass='diff-mod-hard'; Focus='Library/school style systems, interfaces, exam-style design'
    Questions=@(
      @{ N=1; Intro='Full encapsulation review.'; Items=@(
        'Critique a class that exposes public arrays of marks - what can go wrong? <strong>(6 marks)</strong>'
        'Redesign with private data, controlled addMark/getAverage, and validation 0-100. <strong>(10 marks)</strong>'
        'Write a short note on information hiding for a non-technical manager. <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Multi-level inheritance care.'; Items=@(
        'Write inheritance chain Vehicle -&gt; Car -&gt; ElectricCar with one new field/method at each level. <strong>(10 marks)</strong>'
        'Show constructor chaining with <code>super</code> at each level. <strong>(6 marks)</strong>'
        'State one risk of deep inheritance trees and one alternative (e.g. composition). <strong>(4 marks)</strong>'
      )}
      @{ N=3; Intro='Interface segregation lite.'; Items=@(
        'Define interfaces <code>Borrowable</code> and <code>Reservable</code> with suitable methods. <strong>(6 marks)</strong>'
        'Implement a <code>Book</code> that is borrowable and reservable, and a <code>Magazine</code> that is only borrowable. <strong>(10 marks)</strong>'
        'Why might two small interfaces be better than one large "LibraryItemOps" interface? <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='Polymorphic collections.'; Items=@(
        'Create an abstract <code>Staff</code> with <code>work()</code>; concrete <code>Librarian</code> and <code>Clerk</code>. <strong>(8 marks)</strong>'
        'Store both in a <code>List&lt;Staff&gt;</code> (or array) and invoke <code>work()</code> in a loop. <strong>(6 marks)</strong>'
        'Explain what would break if <code>work</code> were removed from the superclass and only defined in subclasses while the list type stayed <code>Staff</code>. <strong>(6 marks)</strong>'
      )}
      @{ N=5; Intro='Classroom composition.'; Items=@(
        'Write <code>Desk</code> and a <code>Classroom</code> that owns a fixed array/list of desks created in its constructor. <strong>(10 marks)</strong>'
        'Add <code>occupyDesk(int index, String studentName)</code> with bounds checks. <strong>(6 marks)</strong>'
        'Why is this composition rather than a weak association? <strong>(4 marks)</strong>'
      )}
      @{ N=6; Code=@'
class A {
    void hello() { System.out.println("A"); }
}
class B extends A {
    void hello() { System.out.println("B"); }
    void onlyB() { System.out.println("onlyB"); }
}
'@; Intro='Predict and reason.'; Items=@(
        'For <code>A x = new B();</code> which calls compile: <code>x.hello()</code>, <code>x.onlyB()</code>? What prints for the legal call? <strong>(8 marks)</strong>'
        'How can you call <code>onlyB</code> safely using a cast? What risk does a wrong cast bring? <strong>(6 marks)</strong>'
        'Rewrite using an override-only design so clients need no cast for normal use. <strong>(6 marks)</strong>'
      )}
      @{ N=7; Intro='Exam scenario - COT library desk.'; Items=@(
        'A librarian needs to search by title keyword and borrow by ISBN. Outline classes/methods (no full code). <strong>(8 marks)</strong>'
        'Write the <code>matchesSearch(String keyword)</code> method body using <code>toLowerCase</code> / <code>contains</code>. <strong>(6 marks)</strong>'
        'Explain where encapsulation and exceptions would improve this desk system. <strong>(6 marks)</strong>'
      )}
    )
  }

  @{
    Num=9; Difficulty='Hard'; DiffClass='diff-hard'; Focus='Integrated OOP design under constraints, tracing, trade-offs'
    Questions=@(
      @{ N=1; Intro='Design under constraints.'; Items=@(
        'Design a <code>Course</code> registration helper: course code, capacity, enrolled count. Enforce capacity with exceptions. <strong>(8 marks)</strong>'
        'Implement enrol/drop methods with full validation. <strong>(8 marks)</strong>'
        'Discuss whether capacity checks belong in the UI, the domain class, or both. <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Strategy via interfaces.'; Items=@(
        'Create interface <code>DiscountPolicy</code> with <code>double apply(double price)</code>. <strong>(4 marks)</strong>'
        'Implement <code>NoDiscount</code>, <code>PercentOff</code>, and <code>StudentDiscount</code>. <strong>(9 marks)</strong>'
        'Write class <code>Cart</code> that holds a policy and a price, and show switching policies without changing Cart's core code. <strong>(7 marks)</strong>'
      )}
      @{ N=3; Intro='Harder trace.'; Code=@'
class Box {
    int n;
    Box(int n) { this.n = n; }
    void add(Box other) { this.n += other.n; }
}
// main:
Box x = new Box(5);
Box y = x;
Box z = new Box(5);
y.add(z);
System.out.println(x.n + " " + y.n + " " + z.n);
z = y;
z.n = 1;
System.out.println(x.n + " " + y.n + " " + z.n);
'@; Items=@(
        'Give both lines of output. <strong>(8 marks)</strong>'
        'Explain aliasing after <code>Box y = x</code> and after <code>z = y</code>. <strong>(8 marks)</strong>'
        'If <code>add</code> did <code>other = new Box(0)</code> inside the method, would <code>z</code> in <code>main</code> change? Why? <strong>(4 marks)</strong>'
      )}
      @{ N=4; Intro='Abstract factory-lite (manual).'; Items=@(
        'Define abstract <code>Notification</code> with <code>deliver()</code> and concrete Email/SMS types. <strong>(8 marks)</strong>'
        'Write a method <code>Notification create(String type)</code> that returns the right subclass (or throws on unknown type). <strong>(8 marks)</strong>'
        'Explain how this supports open/closed thinking at beginner level. <strong>(4 marks)</strong>'
      )}
      @{ N=5; Intro='School system consistency.'; Items=@(
        'Model Teacher, Classroom, and Student with a mix of association and composition - justify each link. <strong>(8 marks)</strong>'
        'Implement enough Java to add a student to a classroom and list names. <strong>(8 marks)</strong>'
        'What invariant should the model protect (e.g. student not in two seats)? How? <strong>(4 marks)</strong>'
      )}
      @{ N=6; Intro='Error-handling architecture.'; Items=@(
        'Design a layered approach: domain throws, menu catches, logs a simple message. Illustrate with code sketches. <strong>(10 marks)</strong>'
        'Should <code>main</code> catch <code>Exception</code> broadly? Argue for or against for this module's apps. <strong>(6 marks)</strong>'
        'Name two unchecked and one checked exception category example (theory). <strong>(4 marks)</strong>'
      )}
      @{ N=7; Intro='Refactoring challenge.'; Code=@'
class Bad {
    public int[] marks = new int[3];
    public String name;
    public double avg() {
        return (marks[0]+marks[1]+marks[2])/3.0;
    }
}
'@; Items=@(
        'List four concrete problems in <code>Bad</code> (encapsulation, validation, API, misuse). <strong>(8 marks)</strong>'
        'Produce an improved class API and implementation. <strong>(8 marks)</strong>'
        'Show how client code must change and why that is healthier long-term. <strong>(4 marks)</strong>'
      )}
    )
  }

  @{
    Num=10; Difficulty='Hard'; DiffClass='diff-hard'; Focus='Capstone-style design, polymorphism mastery, critique &amp; extension'
    Questions=@(
      @{ N=1; Intro='Capstone design brief.'; Items=@(
        'You must design a console "Campus Lost &amp; Found". Identify at least four classes and their relationships (inherit/associate/compose). <strong>(8 marks)</strong>'
        'Write full Java for an abstract <code>Item</code> and two subclasses with one distinct behaviour each. <strong>(8 marks)</strong>'
        'Describe how a polymorphic list of items would be displayed. <strong>(4 marks)</strong>'
      )}
      @{ N=2; Intro='Contract-first with interfaces.'; Items=@(
        'Define <code>Searchable</code> and <code>Auditable</code> interfaces. <strong>(4 marks)</strong>'
        'Implement a <code>BorrowRecord</code> that supports both; show a method that accepts <code>Searchable</code> only. <strong>(10 marks)</strong>'
        'Explain compile-time vs runtime roles of the interface type. <strong>(6 marks)</strong>'
      )}
      @{ N=3; Intro='Complex override rules.'; Items=@(
        'Write a superclass method that returns <code>Animal</code> and a subclass override that returns <code>Dog</code> (covariant return) - if not taught, explain the safer same-return override pattern instead and implement that. <strong>(8 marks)</strong>'
        'Demonstrate calling the override through a superclass reference. <strong>(6 marks)</strong>'
        'Discuss whether making the superclass method <code>final</code> would help or hurt extensibility here. <strong>(6 marks)</strong>'
      )}
      @{ N=4; Intro='Integrity with composition.'; Items=@(
        'Model an <code>Order</code> composed of <code>OrderLine</code> parts; totals derived from lines. <strong>(8 marks)</strong>'
        'Prevent empty orders and negative quantities with exceptions. <strong>(6 marks)</strong>'
        'Explain cascading lifetime: what happens conceptually when the order is discarded. <strong>(6 marks)</strong>'
      )}
      @{ N=5; Intro='Performance &amp; memory awareness.'; Items=@(
        'Explain how creating thousands of temporary <code>String</code> objects in a loop differs from updating a numeric counter field. <strong>(6 marks)</strong>'
        'Given a library catalogue array, discuss reference cost vs copying objects when "sorting references". <strong>(8 marks)</strong>'
        'How does understanding stack/heap help debug a stubborn NullPointerException? <strong>(6 marks)</strong>'
      )}
      @{ N=6; Intro='Extension without breaking clients.'; Items=@(
        'An existing <code>Printer</code> class is used widely. You must add colour printing variants. Propose an inheritance or interface-based extension that minimises breakage. <strong>(8 marks)</strong>'
        'Provide class/interface sketches and a short client migration note. <strong>(8 marks)</strong>'
        'What regression tests would you run from <code>main</code> after the change? <strong>(4 marks)</strong>'
      )}
      @{ N=7; Intro='Examiner critique.'; Items=@(
        'A student submits a single 400-line <code>Main</code> with no classes. Mark scheme style: award/deduct conceptual marks across OOP pillars - write a structured examiner comment (strengths/weaknesses/advice). <strong>(10 marks)</strong>'
        'Outline a refactor plan into at least five types (classes/interfaces) with responsibilities. <strong>(6 marks)</strong>'
        'Write the method signatures only for the public API of the two most important types. <strong>(4 marks)</strong>'
      )}
    )
  }
)

# Emit HTML
foreach ($p in $papers) {
  $html = New-PaperHtml -Num $p.Num -Difficulty $p.Difficulty -DiffClass $p.DiffClass -Focus $p.Focus -Questions $p.Questions
  $name = 'Model-Paper-{0:D2}-{1}.html' -f $p.Num, ($p.Difficulty -replace '[-\s]','-' -replace '-+','-')
  # cleaner filenames
  $slug = switch ($p.Num) {
    1 { 'Easy' }; 2 { 'Easy' }; 3 { 'Easy-Moderate' }; 4 { 'Easy-Moderate' }
    5 { 'Moderate' }; 6 { 'Moderate' }; 7 { 'Moderate-Hard' }; 8 { 'Moderate-Hard' }
    9 { 'Hard' }; 10 { 'Hard' }
  }
  $file = Join-Path $root ("Model-Paper-{0:D2}-{1}.html" -f $p.Num, $slug)
  Set-Content -Path $file -Value $html -Encoding UTF8
  Write-Host "Wrote $file"
}

# Meta JSON for hub
$meta = foreach ($p in $papers) {
  $slug = switch ($p.Num) {
    1 { 'Easy' }; 2 { 'Easy' }; 3 { 'Easy-Moderate' }; 4 { 'Easy-Moderate' }
    5 { 'Moderate' }; 6 { 'Moderate' }; 7 { 'Moderate-Hard' }; 8 { 'Moderate-Hard' }
    9 { 'Hard' }; 10 { 'Hard' }
  }
  [pscustomobject]@{
    Num = $p.Num
    Difficulty = $p.Difficulty
    Slug = $slug
    Focus = ($p.Focus -replace '&amp;','&')
    Pdf = ("Model-Paper-{0:D2}-{1}.pdf" -f $p.Num, $slug)
    Html = ("Model-Paper-{0:D2}-{1}.html" -f $p.Num, $slug)
  }
}
$meta | ConvertTo-Json | Set-Content (Join-Path $root '_papers-meta.json') -Encoding UTF8
Write-Host 'HTML generation complete.'
