:Namespace IIPageStats
⍝ Future/Isolate code sample    
⍝   Report 'al' 
⍝   ... to get a letter frequency count for home pages of newspapers in Alaska

    (⎕IO ⎕ML)←1
    alphabet←'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'  
    
    ∇ pages←PapersInState state;text;ignore
     ⍝ Retrieve list of home pages of major newspapers in named state
     ⍝ Thanks to USNPL.com - the US NewsPaper List
     
      ignore←'maps.google.com' 'www.yahoo.com' 'www.ebay.com' 'www.imdb.com'
      ignore,←'news.google.com' 'fedex.com' 'www.ups.com' 'www.abcnews.com' 'www.usps.com'
      ignore←'http://'∘,¨ignore,¨'/'
     
      text←GetPage'http://www.usnpl.com/',state,'news.php'
      pages←('(<a href=")(.*?)(.com/">)'⎕S'\2.com/')text      ⍝ All href's to a .com
      pages←pages~ignore
    ∇

    ∇ freq←CountChars html;text
    ⍝ Return a frequency count for letters outside tage in an HTML page
     
      text←('<.*?>'⎕R'')html     ⍝ Remove all (well, lots of) HTML tags
      text←(text∊alphabet)/text  ⍝ Remove all irrelevant chars
      freq←{⍺(≢⍵)}⌸text
    ∇

    ∇ r←CountPageChars url;text
      ⍝ Return letter frequency count for a URL
     
      ⎕←⎕TS('Counting chars for: ',url)
      :Trap 0 ⋄ text←GetPage url
      :Else ⋄ text←'' ⋄ :EndTrap
     
      r←CountChars text
      ⎕←'      ... done ...'
    ∇

    ∇ freq←{nprocs}Report state;pages;html;iss;cap;PF;AI3
      AI3←⎕AI[3]
      :If 0=⎕NC'nprocs' ⋄ nprocs←#.isolate.Config'processors' ⋄ :EndIf ⍝ Default to use all processors
     
      ⎕EX'bars'           ⍝ make sure we don't have this global
     
      iss←#.ø¨nprocs⍴⎕THIS ⍝ Clone this namespace nprocs times
     
      pages←PapersInState state
      cap←'State "',state,'" has ',(⍕≢pages),' major papers.'
     
      bars←cap MakeProgressForm nprocs,≢pages
      2 ⎕NQ'.' 'Flush'
      freq←('CountPageChars' '#.IIPageStats.ProgressUpdate'IÏX iss)pages
      ⎕EX'bars'
     
      freq←⊃⍪/freq
      freq←¯1+(alphabet,freq[;1]){+/⍵}⌸(1⍴⍨≢alphabet),freq[;2]
      freq←alphabet,⍪freq
      freq←freq[⍒freq[;2];]
     
      ⎕←'Elapsed seconds: ',1⍕⎕AI[3]-AI3
    ∇

    ∇ r←ProgressUpdate arg
      bars.Thumb←arg
      r←⍬
    ∇
        
    ∇ r←{left}(fns IÏX iss)right;dyadic;fn;cb;n;counts;shape;ni;i;count;done;failed;next;run1iso;callbk;expr;z
    ⍝ Extended parallel each:
    ⍝ iss is a list of refs to pre-existing isolates to use
    ⍝ fn is char vec name of function expected to be in supplied isolates
    ⍝ fn can be nested vec of two fn names, in which case 2nd name is a progress callback
     
      :If dyadic←2=⎕NC'left' ⍝ Scalar extension
          :If 1=×/⍴left ⋄ left←(⍴right)⍴left
          :ElseIf 1=×/⍴right ⋄ right←(⍴left)⍴right
          :EndIf
      :EndIf
     
      :If 2=≡fns ⋄ (fn cb)←fns
      :Else ⋄ fn←fns ⋄ cb←'⊣' ⋄ :EndIf
      callbk←⍎cb
     
      ni←≢iss
      shape←⍴right
      n←⍴right←,right ⋄ :If dyadic ⋄ left←,left ⋄ :EndIf
      counts←ni⍴0 ⋄ done←failed←n⍴count←0
      r←n⍴⎕NULL
     
      run1iso←{⍝ drive isolate ⍵ until we are done
          n<next←⎕THIS.(count←count+1):0 ⍝ no more to do
          r[next]←⊂⍎expr
          counts[⍺]+←1
          z←{0::failed[⍵]←1 ⋄ done[⍵]←1⊣+r[⍵]}next ⍝ Reference it
          ⎕←⎕TID next(right[next])counts count
          z←callbk counts,count⌊n
          ⍺ ∇ ⍵  ⍝ loop until done
      }
     
      expr←(dyadic/'(next⊃left) '),'⍵.',fn,' next⊃right'
      :If 1=≢iss ⍝ Only one: do it in main thread
          z←1 run1iso⊃iss
      :Else
          ⎕TSYNC(⍳ni)run1iso&¨iss
      :EndIf
    ∇
              
    ∇ bars←caption MakeProgressForm(procs items);p;labels;pos;pb;n
    ⍝ Make a form with a progress bar per process and one for the total
     
      'PF'⎕WC'Form'caption('Coord' 'Pixel')('Size'((40+25×procs)800))
      bars←(1+procs)⍴PF
      labels←({'Isolate ',⍕⍵}¨⍳procs),⊂'Total'
     
      :For p :In ⍳1+procs
          pos←10+25×p-1
          ('PF.L',⍕p)⎕WC'Label'(p⊃labels)(pos 20)(⍬ 60)
          (n←'PF.PB',⍕p)⎕WC'ProgressBar'((pos+3)80)(⍬ 700)('Limits'(0 items))
          bars[p]←⍎n
      :EndFor
    ∇

    :Section HTTP Tools  
    
    ∇ r←GetPage url;headers;rc;z
    ⍝ Get an HTTP page - throw any errors using ⎕SIGNAL
      →(0=1⊃(rc headers r)←3↑z←HTTPGet url)⍴0
      (⍕z)⎕SIGNAL 11
    ∇

    ∇ r←{certs}HTTPGet url;U;DRC;protocol;wr;key;flags;pars;secure;data;z;header;datalen;host;port;done;cmd;b;page;auth;p;x509;priority;err;req;fromutf8;chunked;chunk;h2d;buffer;chunklength;len;getchunklen;m;split;NL
     ⍝ Copied from CONGA workspace Samples namespace
     ⍝ Get an HTTP page, format [HTTP[S]://][user:pass@]url[:port][/page]
     ⍝ Opional Left argument: PublicCert PrivateKey SSLValidation
     ⍝ Makes secure connection if left arg provided or URL begins with https:
     
     ⍝ Result: (return code) (HTTP headers) (HTTP body) [PeerCert if secure]
     
      ⍝ ↓↓↓ This is not in the original CONGA sample
      :If 0∊m←#.⎕NC z←'HTTPUtils' 'DRC'
          :Trap 11
              (↑(m=0)/z)#.⎕CY'conga'
          :Else
              (↑(m=0)/z)#.⎕CY'ws\conga'
          :EndTrap
     
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
                  ⎕←wr[1],⍴4⊃wr
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

    :EndSection HTTP Tools

:EndNamespace 