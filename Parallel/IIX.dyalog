:Namespace IIX
⍝ Parallel Extensions.
        
    ∇ r←{left}(fns PEACH iss)right;dyadic;fn;cb;n;counts;shape;ni;i;count;done;failed;next;run1iso;callbk;expr;z;PF;cblarg
    ⍝ IÏ using persistent Isolates:
    ⍝
    ⍝ iss is a list of refs to pre-existing isolates to use
    ⍝     or if scalar, processors×processes clones will be made
    ⍝
    ⍝ fns is either:
    ⍝     a simple char vec name of function expected to be in supplied isolates
    ⍝     a nested vec of two fn names, in which case 2nd name is a progress callback
    ⍝     use empty callback fn for default display
     
      :If dyadic←2=⎕NC'left' ⍝ Scalar extension
          :If 1=×/⍴left ⋄ left←(⍴right)⍴left
          :ElseIf 1=×/⍴right ⋄ right←(⍴left)⍴right
          :EndIf
      :EndIf
     
      :If 0=≢iss ⋄ iss←⊂'' ⋄ :EndIf
      :If 0=⍴⍴iss ⍝ If scalar, clone
          iss←#.isolate.{New¨(×/Config¨'processors' 'processes')⍴⍵}iss
      :EndIf
     
      :If 2=≡fns ⍝ We have a callback function
          (fn cb cblarg)←3↑fns,'' ''
          cblarg,←(0=≢cblarg)/'IIX.PEACH Progress - ',fn,' (',(⍕×/⍴right),')'
          :If 0=⍴cb  ⍝ Default Progress Form
              :If PEACHForm cblarg(≢iss)(×/⍴right)
                  cb←'PEACHUpdate'
              :EndIf
          :EndIf ⍝ Default
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
          z←cblarg callbk counts,count⌊n
          ⍺ ∇ ⍵  ⍝ loop until done
      }
     
      expr←(dyadic/'(next⊃left) '),'⍵.{',(dyadic/'⍺ '),fn,'⍵} next⊃right'
      :If 1=≢iss ⍝ Only one: do it in main thread
          z←1 run1iso⊃iss
      :Else
          z←⎕TSYNC(⍳ni)run1iso&¨iss
      :EndIf
    ∇
              
    ∇ r←PEACHForm(caption nprocs nitems);p;labels;pos;pb;n
    ⍝ Make a progress form with a progress bar per process and one for the total
     
      :Trap 0
          r←1⊣'PF'⎕WC'Form'caption('Coord' 'Pixel')('Size'((40+25×nprocs)800))('EdgeStyle' 'Dialog')('Border' 2)
          PF.Caption←caption ⍝ /// Work around bug
      :Else ⋄ →r←0 ⍝ Unable to create a form
      :EndTrap
      PF.texts←PF.bars←(1+nprocs)⍴PF
      labels←({'Isolate ',⍕⍵}¨⍳nprocs),⊂'Started'
     
      :For p :In ⍳1+nprocs
          pos←10+25×p-1
          ('PF.L',⍕p)⎕WC'Label'(p⊃labels)(pos 20)(⍬ 60)
          (n←'PF.T',⍕p)⎕WC'Label' '0'(pos 70)(⍬ 30)('justify' 'right')
          PF.texts[p]←⍎n
          (n←'PF.PB',⍕p)⎕WC'ProgressBar'((pos+3)110)(⍬ 655)('Limits'(0 nitems))
          PF.bars[p]←⍎n
      :EndFor
      2 ⎕NQ'.' 'Flush'
    ∇

    ∇ {r}←cap PEACHUpdate arg
      PF.texts.Caption←⍕¨arg
      PF.bars.Thumb←arg
      PF.Caption←cap ⍝ /// Work around bug
      r←⍬
    ∇

:EndNamespace