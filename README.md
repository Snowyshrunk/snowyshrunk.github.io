<!DOCTYPE html> 
<html>
    <style>
        #nav {
            background: #2f0431;
            text-align: center;
            overflow: auto;
            position: relative;
            width: 100%
            
        }
        #nav p {
            font-size: 140%;
            position: relative;
            color: #909090;
            top: 30px;
        }
        #nav h1{
            font-size: 350%;
            position: relative;
            color: #e0e0e0;        
            position: relative;
            top: -20px;
            height: 80px;
        }
        .intr {
            border: 2px solid #3a3a3a;
            background-color: #3a3a3a;
            text-align: left;
            left: 0px;
            width: 280px;
            height: 650px;
            position: relative;
            top: auto;
        }
        .intr p {
            font-size: 150%;
            color: #e0e0e0;
        }
        .intr dl {
            color: #e0e0e0;
        }
        .main {
            text-align: left;
            position: relative; 
            left: 300px;
            top: -650px;
            width: 80%;
            height: 500px;
            
        
        }
        .main p {
            color: #e0e0e0;
            font-size: large;
        }
        .main h2 {
            font-size: 80%;
            color: #e0e0e0;
            position: relative;
            top: 20px;
        }
        .links{

            position: relative;
            top: -750px;
            left: 300px;
        }
        .links p{
            color: aqua;
            left: 400px;
        
        }
        .collapsible {
            background-color: #3a3a3a;
            color: #e0e0e0;
            cursor: pointer;
            padding: 0px;
            border: none;
            text-align: left;
            outline: none;
            font-size: 15px;
        }
        .active .collapsible{
            background-color: #3a3a3a;
        }
        .content {
            padding: 0 18px;
            background-color: #3a3a3a;
            max-height: 0;
            font-size: 15px;
            overflow: hidden;
            transition: max-height 0.2s ease-out;
        }
        .collapsible:after {
            content: '\1F892'; /* Unicode character for "plus" sign (+) */
            font-size: 15px;
            color: #e0e0e0;
            float: right;
            margin-left: 5px;

        }

        .active:after {
            font-size: 15px;
            content: "\1F893"; /* Unicode character for "minus" sign (-) */
        }
    </style>
<head>
    <div id = "nav">
        <title>Snowy</title>
        <p> Hi i'm</p>
        <h1>Snowy</h1>
    </div>
</head>
<body style = "background-color: #2F2F2F;">
    <div class = "intr"> 
        <p>  <u>Intrests:</u></p>
        <button type="button" class="collapsible">Coding</button>
        <div class="content">
            <p style="font-size: 15px;">-Python<br>- PY-cord<br>- HTML (obviosly)
        </div>
        <button type="button" class="collapsible">Water sports</button>
        <div class="content">
            <p style="font-size: 15px;">- White water kayaking<br>- canoeing<br>- paddle boarding
        </div>
        <div style="height: 200px;">
            <p style=" font-size: 15px; height: -500px;" >Gaming<br> Climbing<br> PC Building<br> D&D
        </div>
    </div>
    <script>
        var coll = document.getElementsByClassName("collapsible");
        var i;
        
        for (i = 0; i < coll.length; i++) {
          coll[i].addEventListener("click", function() {
            this.classList.toggle("active");
            var content = this.nextElementSibling;
            if (content.style.maxHeight){
              content.style.maxHeight = null;
            } else {
              content.style.maxHeight = content.scrollHeight + "px";
            }
          });
        }
        </script>
    <div class = "main">
        <h1 style=" color: #e0e0e0;"><u> About me</u></h1>
        <p>I currently go by Snowy, but you might also know me as Shrunkmarrow708. <br>
            Im a dyslexic 17-year-old college student that lives in the UK <br></p>
            <p>I enjoy playing a variety of games with my friends and coding in python as part of this have made a couple of discord bots<br>
                I have also started to learn HTML and decided to make this website dont ask why. <br>
                I spend a lot of my time listening to music or watching YouTube. <br>
                some of my hobbies are white water kayaking, climbing<br>
                while i may be dyslexic i am still a good reader and enjoy reading books but cant spell and my hand writing is shit<br>

            </p>
                
                <h2> as u can see im really not that interesting idk why i made this ;-;</h2>
        
    </div>
    <div class = "links">
        <h1 style=" color: #e0e0e0;"> <u>Links:</u></h1>
        <p><a style = color:aqua; href="https://discord.gg/K9TVeCBPuM">Discord server</a></p>
        <p><a style="color: #e0e0e0;">Discord Bots:</a></p>
        <p><a style = color:aqua; href="https://top.gg/bot/1041320378137587762">Snowflake</a></p>
        <p><a style = color:aqua; href="https://top.gg/bot/1161697414013534378">Avalanche</a></p>
    </div>
</body>
</html>
