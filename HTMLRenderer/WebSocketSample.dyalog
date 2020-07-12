 resp←WebSocketSample args;title;html;obj;ev;wsid;url;data;type;fin;reason;code;fn;show;⎕ML;⎕IO
     ⍝ general websocket test framework
     ⍝ use this function in conjunction with ∇Send
 ⎕ML←⎕IO←1
 show←{n←' '(≠⊆⊢)⍺ ⋄ n,⍪{len←≢⍵ ⋄ ↑⍕{⍵⊆⍨~⍵∊⎕UCS 13 10}{(⍕len),'⍴',(200↑⍵),'...'}⍣(200<len)⊢⍵}∘⍕¨(≢n)↑⍵}
StartHTML:→EndHTML
     ⍝  <!DOCTYPE html>
     ⍝  <html>
     ⍝  <head>
     ⍝  <meta charset="utf-8" />
     ⍝  <title>WebSocket Sample</title>
     ⍝  <script>
     ⍝
     ⍝  var wsroot = "ws://dyalog_root/";
     ⍝  var ws1;
     ⍝
     ⍝  function init()
     ⍝  {
     ⍝    output = document.getElementById("output");
     ⍝    instructions = document.getElementById("instructions");
     ⍝    doOpen(wsroot);
     ⍝  }
     ⍝
     ⍝  function doOpen(root){
     ⍝    ws1 = new WebSocket(root);
     ⍝    ws1.onopen = function(evt) { onOpen(evt) };
     ⍝    ws1.onclose = function(evt) { onClose(evt) };
     ⍝    ws1.onmessage = function(evt) { onMessage(evt) };
     ⍝    ws1.onerror = function(evt) { onError(evt) };
     ⍝  }
     ⍝
     ⍝  function doRecycle(){
     ⍝    try {
     ⍝      doClose();
     ⍝    }
     ⍝    catch(err) {
     ⍝      writeToScreen(err.message);
     ⍝    }
     ⍝    doOpen(wsroot);
     ⍝  }
     ⍝
     ⍝  function onOpen(evt)
     ⍝  {
     ⍝    writeToScreen("Opening websocket");
     ⍝  }
     ⍝
     ⍝  function onClose(evt)
     ⍝  {
     ⍝    writeToScreen("Websocket closed");
     ⍝  }
     ⍝
     ⍝  function doClose()
     ⍝  {
     ⍝    writeToScreen("Closing websocket");
     ⍝    ws1.close(1000, "Bye Bye");
     ⍝  }
     ⍝
     ⍝  function onMessage(evt)
     ⍝  {
     ⍝    writeToScreen('<span style="color: blue;">Received: </span>' + evt.data);
     ⍝  }
     ⍝
     ⍝  function onError(evt)
     ⍝  {
     ⍝    writeToScreen('<span style="color: red;">ERROR: </span>' + evt.data);
     ⍝  }
     ⍝
     ⍝  function doSend(message)
     ⍝  {
     ⍝    if (ws1===undefined){
     ⍝      alert("Open the WebSocket first please");
     ⍝    }
     ⍝    else {
     ⍝      ws1.send(message);
     ⍝      writeToScreen('<span style="color: green;">Sent: </span>' + message);
     ⍝    }
     ⍝  }
     ⍝
     ⍝  function writeToScreen(message){
     ⍝    var pre = document.createElement("div");
     ⍝    pre.innerHTML = now() + " " +message;
     ⍝    output.appendChild(pre);
     ⍝    pre.scrollIntoView();
     ⍝  }
     ⍝
     ⍝  function sendChar()
     ⍝  {
     ⍝    var msg = document.getElementById("inp").value;
     ⍝    doSend(msg);
     ⍝  }
     ⍝
     ⍝  toggle = () => {
     ⍝    instructions.style.display = (instructions.style.display !=="none") ? "none" : "block";
     ⍝    output.style.display = (output.style.display ==="none") ? "block" : "none";
     ⍝  }
     ⍝
     ⍝  now = () =>{
     ⍝    var d = new Date();
     ⍝    return d.getUTCFullYear()+'-'+zpad(2,1+d.getUTCMonth())+'-'+zpad(2,d.getUTCDate())+' '+zpad(2,d.getUTCHours())+':'+zpad(2,d.getUTCMinutes())+':'+zpad(2,d.getUTCSeconds())+'.'+zpad(3,d.getUTCMilliseconds());
     ⍝  }
     ⍝
     ⍝  zpad = (n,str) =>{ return ("0".repeat(n)+str).substr(-n,n) }
     ⍝
     ⍝  // window.addEventListener("load", init, false);
     ⍝
     ⍝  </script>
     ⍝  <style>
     ⍝  body,html{padding:0px 10px;margin:0;}
     ⍝  #outer{display:flex;flex-direction:column;height:95vh;}
     ⍝  .div{padding:2px 10px;border:solid 1px;margin-top:5px;}
     ⍝  #output{flex:1;overflow:auto;min-height:0px;}
     ⍝  .lbutt{margin-right:5px;}
     ⍝  .rbutt{float:right;margin-right:5px;}
     ⍝  a{margin-right:5px;}
     ⍝  </style>
     ⍝  </head>
     ⍝
     ⍝  <body>
     ⍝  <div id="outer">
     ⍝  <h2>WebSocket Sample</h2>
     ⍝
     ⍝  <div>
     ⍝  <button class='lbutt' type="button" onclick="doOpen(wsroot)">Open</button>
     ⍝  <button class='lbutt' type="button" onclick="sendChar()">Send</button>
     ⍝  <button class='lbutt' type="button" onclick="doClose()">Close</button>
     ⍝  <button class='rbutt' type="button" onclick="output.innerHTML='';">Clear Log</button>&nbsp;&nbsp;
     ⍝  <button class='rbutt' type="button" onclick="toggle('instructions')">Toggle Instructions</button>&nbsp;&nbsp;
     ⍝  </div>
     ⍝  <div><input type="text" style="width:100%;" id="inp"/></div>
     ⍝  <div id="instructions" class="div" style="display:none;">
     ⍝  <pre>
     ⍝
     ⍝  Click "Open" to create the WebSocket.
     ⍝  To send to APL, type something in the input area and click "Send"
     ⍝  To send from APL, in the APL session, use the "Send" function
     ⍝       Send 'this is a test!'
     ⍝
     ⍝  </pre>
     ⍝  </div>
     ⍝
     ⍝  <div id="output" class="flex div"></div>
     ⍝  </div>
     ⍝  </body>
     ⍝  </html>
EndHTML:
 html←'HTML'(1↓∊(⎕UCS 13),¨{⍵↓⍨⍵⍳'⍝'}¨StartHTML↓EndHTML↑⎕NR fn←⊃⎕XSI)
 :If 0∊⍴args
     'hr'⎕WC'HTMLRenderer'html('Event' 'All'fn)('InterceptedURLs'(1 2⍴'ws://dyalog_root/' 1))
     hr.ShowDevTools 1
 :Else
     :Select 2⊃args
     :Case 'WebSocketUpgrade'
         ⎕←'obj ev wsid url hdr auto'show args
         (obj ev wsid url)←4↑args
         resp←args
StartCode:→EndCode
     ⍝         Send parms;msg;type;segs
     ⍝         ⍝ send data to currently open HTMLRenderer/websocket
     ⍝         ⍝ parms [1] msg [2] datatype (1-text, 2-bin)
     ⍝         (msg type)←''  0{(≢⍺)↑⍵,(≢⍵)↓⍺},⊆parms
     ⍝         2 ⎕NQ _hr 'WebSocketSend' _wsid msg 1 ((1+type=0)⊃type,1+(⎕DR'')≠⎕DR msg)
EndCode: ' function defined',⍨⎕FX('_hr' '_wsid'⎕R('''',obj,'''')('''',wsid,'''')){⍵↓⍨⍵⍳'⍝'}¨(1+StartCode)↓EndCode↑⎕NR fn

     :Case 'WebSocketReceive'
         ⎕←'obj ev wsid data type fin'show args
         (obj ev wsid data type fin)←args

     :Case 'WebSocketClose'
         ⎕←'obj ev wsid code reason'show args
         (obj ev wsid code reason)←args

     :Case 'WebSocketError'
         ⎕←'obj ev wsid'show args
     :EndSelect
 :EndIf
