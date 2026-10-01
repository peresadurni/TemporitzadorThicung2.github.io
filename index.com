<!DOCTYPE html>
<html lang="ca">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>Temporitzador Txicung V2</title>
<style>
:root{--text:#203040}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:Arial,sans-serif;height:100dvh;overflow:hidden;background:linear-gradient(-45deg,#dff3ff,#fff,#e7fff5,#f5f0ff);background-size:400% 400%;animation:gradient 25s ease infinite}
@keyframes gradient{0%{background-position:0% 50%}50%{background-position:100% 50%}100%{background-position:0% 50%}}
#timer-container{height:72vh;display:flex;align-items:center;justify-content:center}
#timer{font-size:clamp(7rem,24vw,22rem);font-weight:bold;color:var(--text);animation:breath 6s ease-in-out infinite}
@keyframes breath{0%{transform:scale(1)}50%{transform:scale(1.03)}100%{transform:scale(1)}}
#progress{text-align:center;color:#345;font-size:1.1rem}
#controls-panel{position:fixed;left:50%;transform:translateX(-50%);bottom:max(20px,env(safe-area-inset-bottom));display:flex;gap:12px;flex-wrap:wrap;justify-content:center;align-items:center;background:rgba(255,255,255,.85);padding:14px;border-radius:16px;max-width:95vw}
select,button{padding:10px;border-radius:10px;border:1px solid #bbb}
button{cursor:pointer;color:#fff;border:none}.start{background:#2ecc71}.pause{background:#f39c12}.reset{background:#3498db}.full{background:#6c5ce7}
</style>
</head>
<body>
<div id="timer-container"><div id="timer">0:00</div></div>
<div id="progress">0%</div>
<div id="controls-panel">
<div><label>Durada</label><br><select id="sessionDuration"><option>15</option><option>20</option><option selected>30</option><option>45</option><option>60</option></select></div>
<div><label>Interval</label><br><select id="intervalMinutes"><option>3</option><option selected>5</option><option>10</option><option>15</option></select></div>
<div><label>So</label><br><select id="soundType"><option value="tibetan">Gong tibetà</option><option value="japanese">Campana japonesa</option><option value="quartz">Bol de quars</option></select></div>
<button class="start" onclick="startTimer()">Inicia</button>
<button class="pause" onclick="pauseTimer()">Pausa</button>
<button class="reset" onclick="resetTimer()">Reinicia</button>
<button class="full" onclick="toggleFullscreen()">Pantalla completa</button>
</div>
<script>
let elapsed=0,timer=null;
function maxTime(){return Number(document.getElementById('sessionDuration').value)*60}
function update(){let m=Math.floor(elapsed/60),s=elapsed%60;document.getElementById('timer').textContent=m+':'+String(s).padStart(2,'0');document.getElementById('progress').textContent=Math.round((elapsed/maxTime())*100)+'%';}
function tone(f,d,v=0.2){const c=new(window.AudioContext||window.webkitAudioContext)(),o=c.createOscillator(),g=c.createGain();o.type='sine';o.frequency.value=f;g.gain.value=v;g.gain.exponentialRampToValueAtTime(.0001,c.currentTime+d);o.connect(g);g.connect(c.destination);o.start();o.stop(c.currentTime+d)}
function playMind(){let s=document.getElementById('soundType').value;if(s==='tibetan'){tone(220,3,.3);setTimeout(()=>tone(330,3,.15),100)}if(s==='japanese'){tone(523,2,.2)}if(s==='quartz'){tone(880,2,.18)}}
function playFinal(){tone(262,1,.25);setTimeout(()=>tone(392,2,.2),700);setTimeout(()=>tone(523,3,.15),1300)}
function startTimer(){if(timer) return;timer=setInterval(()=>{elapsed++;update();let iv=Number(document.getElementById('intervalMinutes').value)*60;if(elapsed>0&&elapsed%iv===0&&elapsed<maxTime())playMind();if(elapsed>=maxTime()){clearInterval(timer);timer=null;playFinal();alert('Sessió finalitzada');}},1000)}
function pauseTimer(){clearInterval(timer);timer=null}
function resetTimer(){pauseTimer();elapsed=0;update()}
function toggleFullscreen(){if(!document.fullscreenElement){document.documentElement.requestFullscreen()}else{document.exitFullscreen()}}
update();
</script>
</body></html>
