:Namespace IIPageStats
⍝ Future/Isolate code sample, using #.IIX.PEACH    
⍝   Report 'al' 
⍝   ... to get a letter frequency count for home pages of newspapers in Alabama

    (⎕IO ⎕ML)←1
    alphabet←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'  
    
    ∇ freq←{nprocs}Report state;pages;html;cap;PF;AI3;iss
      AI3←⎕AI[3]
     
      :If 0=⎕NC'nprocs' ⋄ nprocs←#.isolate.Config'processors' ⋄ :EndIf ⍝ Default to use all processors
      iss←#.ø¨nprocs⍴⎕THIS ⍝ Make isolates
     
      pages←PapersInState state
      cap←'Processing ',(⍕≢pages),' major papers in state "',state,'"'
      freq←('CountPageChars' ''cap #.IIX.PEACH iss)pages
      freq←⊃+/freq
      freq←(26↑alphabet),⍪+⌿2 26⍴freq
      freq←freq[⍒freq[;2];]
     
      ⎕←'Elapsed seconds for ',state,': ',1⍕⎕AI[3]-AI3
    ∇

    ∇ pages←PapersInState state;text;ignore;txt
     ⍝ Retrieve list of home pages of major newspapers in named state
     ⍝ Thanks to USNPL.com - the US NewsPaper List
     
      text←GetPage'http://www.usnpl.com/',state,'news.php'
     
      ⍝ ↓↓↓ extract the body containing newpaper page links
      txt←(('for address downloads.'⍷text)⍳1)↓text
      txt←(5+('</div>'⍷txt)⍳1)↓txt
      txt←(¯1+('</body>'⍷txt)⍳1)↑txt
     
      pages←('(<a href=")(.*?)(.com/">)'⎕S'\2.com/')txt      ⍝ All href's to a .com
    ∇

    ∇ r←CountPageChars url;text;html
      ⍝ Return letter frequency count for a URL
     
      html←{0::'' ⋄ GetPage ⍵}url
      text←('<.*?>'⎕R'')html     ⍝ Remove all (well, lots of) HTML tags
      text←(text∊alphabet)/text  ⍝ Remove all irrelevant chars
      r←¯1+{≢⍵}⌸alphabet,text    ⍝ Frequency count
    ∇

    :Section HTTP Tools

    ∇ r←GetPage url;headers;rc;z
    ⍝ Get an HTTP page - throw any errors using ⎕SIGNAL
      →(0=1⊃(rc headers r)←3↑z←HTTPGet url)⍴0
      (⍕z)⎕SIGNAL 11
    ∇

    ∇ r←{certs}HTTPGet url;U;DRC;protocol;wr;key;flags;pars;secure;data;z;header;datalen;host;port;done;cmd;b;page;auth;p;x509;priority;err;req;fromutf8;chunked;chunk;h2d;buffer;chunklength;len;getchunklen;m;split;NL;ws
     ⍝ Copied from CONGA workspace Samples namespace
     ⍝ Get an HTTP page, format [HTTP[S]://][user:pass@]url[:port][/page]
     ⍝ Opional Left argument: PublicCert PrivateKey SSLValidation
     ⍝ Makes secure connection if left arg provided or URL begins with https:
     
     ⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
     
      ⍝ ↓↓↓ This is not in the original CONGA sample
      ⍝ ↓↓↓ Replace when CONGA sample updated
      :If 0∊m←#.⎕NC z←'HTTPUtils' 'DRC'
          ws←(2 ⎕NQ'.' 'GetEnvironment' 'dyalog'),'/WS/conga'
          (↑(m=0)/z)#.⎕CY ws
      :EndIf
     
      (U DRC)←#.(HTTPUtils DRC) ⍝ Uses utils from here
      fromutf8←{0::(⎕AV,'?')[⎕AVU⍳⍵] ⋄ 'UTF-8'⎕UCS ⍵} ⍝ Turn raw UTF-8 input into text
      h2d←{⎕IO←0 ⋄ 16⊥'0123456789abcdef'⍳U.lc ⍵} ⍝ hex to decimal
      getchunklen←{¯1=len←¯1+⊃(NL⍷⍵)/⍳⍴⍵:¯1 ¯1 ⋄ chunklen←h2d len↑⍵ ⋄ (⍴⍵)<len+chunklen+4:¯1 ¯1 ⋄ len chunklen}
      split←{(p↑⍵)((p←¯1+⍵⍳⍺)↓⍵)}
      NL←⎕UCS 13 10
     
      {}DRC.Init''
     
     GET:
      p←(∨/b)×1+(b←'//'⍷url)⍳1
      secure←{6::⍵ ⋄ ⍵∨0<⍴certs}(U.lc(p-2)↑url)≡'https:'
      port←(1+secure)⊃80 443 ⍝ Default HTTP/HTTPS port
      url←p↓url              ⍝ Remove HTTP[s]:// if present
      host page←'/'split url,(~'/'∊url)/'/'    ⍝ Extract host and page from url
     
      :If 0=⎕NC'certs' ⋄ certs←'' ⋄ :EndIf
     
      :If secure
          x509 flags priority←3↑certs,(⍴,certs)↓(⎕NEW ##.DRC.X509Cert)32 'NORMAL:!CTYPE-OPENPGP'  ⍝ 32=Do not validate Certs
          pars←('x509'x509)('SSLValidation'flags)('Priority'priority)
      :Else ⋄ pars←''
      :EndIf
     
      :If '@'∊host ⍝ Handle user:password@host...
          auth←NL,'Authorization: Basic ',(U.Encode(¯1+p←host⍳'@')↑host)
          host←p↓host
      :Else ⋄ auth←''
      :EndIf
     
      host port←port U.HostPort host ⍝ Check for override of port number
     
      req←'GET ',page,' HTTP/1.1',NL,'Host: ',host,NL,'User-Agent: Dyalog/Conga',NL,'Accept: */*',auth,NL ⍝ build the request
     
      :If DRC.flate.IsAvailable ⍝ if compression is available
          req,←'Accept-Encoding: deflate',NL ⍝ indicate we can accept it
      :EndIf
     
      :If 0=⊃(err cmd)←2↑r←DRC.Clt''host port'Text' 100000,pars ⍝ 100,000 is max receive buffer size
      :AndIf 0=⊃r←DRC.Send cmd(req,NL)
     
          chunked chunk buffer chunklength←0 '' '' 0
          done data datalen header←0 ⍬ 0(0 ⍬)
          :Repeat
              :If ~done←0≠1⊃wr←DRC.Wait cmd 5000            ⍝ Wait up to 5 secs
                  :If wr[3]∊'Block' 'BlockLast'             ⍝ If we got some data
                      :If chunked
                          chunk←4⊃wr
                      :ElseIf 0<⍴data,←4⊃wr
                      :AndIf 0=1⊃header
                          header←U.DecodeHeader data
                          :If 0<1⊃header
                              data←(1⊃header)↓data
                              :If chunked←∨/'chunked'⍷(2⊃header)U.GetValue'Transfer-Encoding' ''
                                  chunk←data
                                  data←''
                              :Else
                                  datalen←⊃((2⊃header)U.GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
                              :EndIf
                          :EndIf
                      :EndIf
                  :Else
                      ⎕←wr ⍝ Error?
                      ∘∘∘
                  :EndIf
                  :If chunked
                      buffer,←chunk
                      :While done<¯1≠⊃(len chunklength)←getchunklen buffer
                          :If (⍴buffer)≥4+len+chunklength
                              data,←chunklength↑(len+2)↓buffer
                              buffer←(chunklength+len+4)↓buffer
                              :If done←0=chunklength ⍝ chunked transfer can add headers at the end of the transmission
                                  header[2]←⊂(2⊃header)⍪2⊃U.DecodeHeader buffer
                              :EndIf
                          :EndIf
                      :EndWhile
                  :Else
                      done←done∨'BlockLast'≡3⊃wr                        ⍝ Done if socket was closed
                      :If datalen>0
                          done←done∨datalen≤⍴data ⍝ ... or if declared amount of data rcvd
                      :Else
                          done←done∨(∨/'</html>'⍷data)∨(∨/'</HTML>'⍷data)
                      :EndIf
                  :EndIf
              :EndIf
          :Until done
     
          :Trap 0 ⍝ If any errors occur, abandon conversion
              :If ∨/'deflate'⍷(2⊃header)U.GetValue'content-encoding' '' ⍝ was the response compressed?
                  data←fromutf8 DRC.flate.Inflate 120 156,256|83 ⎕DR data ⍝ append 120 156 signature because web servers strip it out due to IE
              :ElseIf ∨/'charset=utf-8'⍷(2⊃header)U.GetValue'content-type' ''
                  data←'UTF-8'⎕UCS ⎕UCS data ⍝ Convert from UTF-8
              :EndIf
          :EndTrap
     
          :If {(⍵[3]∊'12357')∧'30 '≡⍵[1 2 4]}4↑{⍵↓⍨⍵⍳' '}(⊂1 1)⊃2⊃header ⍝ redirected? (HTTP status codes 301, 302, 303, 305, 307)
              →GET⍴⍨0<⍴url←'location'{(⍵[;1]⍳⊂⍺)⊃⍵[;2],⊂''}2⊃header ⍝ use the "location" header field for the URL
          :EndIf
     
          r←(1⊃wr)(2⊃header)data
     
          :If secure ⋄ r←r,⊂DRC.GetProp cmd'PeerCert' ⋄ :EndIf
      :Else
          'Connection failed ',,⍕r
      :EndIf
     
      z←DRC.Close cmd
    ∇

    :EndSection ⍝ HTTP Tools

:EndNamespace 