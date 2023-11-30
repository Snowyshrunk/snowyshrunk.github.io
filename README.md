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
        .pic {
            position: relative;
            top: -950px;
            left: 1200px;
        }
        .pic p {
            color: #e0e0e0;
        }
        .vid {
            position: relative;
            top: -1800px;
            left: 1200px;
        }
        .vid p {
            color: #e0e0e0;
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
        .card{
            position: relative;
            top: 500px;
            left: 40%;
        }
        .card p {
            color: #e0e0e0;
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
        .big_margin {
            margin-left: 20px;
            margin-right: 20px;
        }
        .big_marginr {
            margin-right: 80px;
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
            <p style="font-size: 15px;">-Python<br>- PY-cord<br>- HTML (obviously)
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
                2 of my of my hobbies are white water kayaking and climbing<br>
                while i may be dyslexic i am still a good reader but my hand writing and spelling are really shit<br>

            </p>
                
                <h2> as u can see im really not that interesting idk why i made this ;-;</h2>
        
    </div>
    <div class = "links">
        <h1 style=" color: #e0e0e0; size: 10px;"> <font size="4"><u>Links:</u></font></h1>
        <p>
            <a class="big_marginr"  style = color:aqua; href="https://github.com/Snowyshrunk/">Github</a>
            <a class="big_marginr" style = color:aqua; href="https://discord.gg/K9TVeCBPuM">Discord server</a>
            <a class="big_margin" style="color: #e0e0e0;">Discord Bots:</a>
            <a class="big_margin" style = color:aqua; href="https://top.gg/bot/1041320378137587762">Snowflake</a>
            <a class="big_margin" style = color:aqua; href="https://top.gg/bot/1161697414013534378">Avalanche</a>
            <a class="big_margin" style = color:aqua; href="https://github.com/Snowyshrunk/Discord-bots-snowy708">Code</a>
        </p>
    </div>
    <div class = "pic">
        <img src="spotify_2023_wraped.jpeg" alt="image" height = "470" width="300"/>
        <p> i listen to music way too much</p>
    </div>
    <div class = "vid">
        <video src="hand_role.mp4" autoplay muted loop height= "200" width="300">
            <p>
              Oh no! Your browser doesn't support video ;-;.<br>
              id and a YouTube link but icba
            </p>
          </video> 
        <p> idk why but heres a vid of me rolling a kayak<br>
            with my hands.<br> 
            why this vid? cause its only interesting vid<br> 
            i had on hand at the time of writing this
        </p>         
    </div>
    <div class = "card">
        <p> if u scrolled this far<br> WELL DONE!!<br> you win my bank details<br>
        </p>
        <img src = "visa_card.png" alt="card pic" height="200" width="320"/> 
    </div>
</body>
</html>
