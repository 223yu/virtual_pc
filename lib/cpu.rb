class CPU
  attr_accessor :pr, :sp, :fr, :gr0, :gr1, :gr2,
                :gr3, :gr4, :gr5, :gr6, :gr7
  # プロパティ
  def initialize(pr=0, sp=49, fr=[0,0,0], gr0='', gr1='', gr2='',
                gr3='', gr4='', gr5='', gr6='', gr7='')
    @pr = pr
    @sp = sp
    @fr = fr
    @gr0 = gr0
    @gr1 = gr1
    @gr2 = gr2
    @gr3 = gr3
    @gr4 = gr4
    @gr5 = gr5
    @gr6 = gr6
    @gr7 = gr7
  end

  # メソッド
  # 制御部
  def control(memory)
    while true
      # 命令の読み出し（フェッチ）
      ir = memory.send("m#{pr}")
      self.pr += 1
  
      # オペコードの解読
      case ir[1]
      when 'LD' then
        read_data(ir[2], memory)
        ld(ir[2])
      when 'LAD' then
        lad(ir[2])
      when 'POP' then
        pop(ir[2], memory)
      when 'ST' then
        st(ir[2], memory)
      when 'PUSH' then
        push(ir[2], memory)
      when 'ADDA' then
        read_data(ir[2], memory)
        adda(ir[2])
      when 'ADDL' then
        read_data(ir[2], memory)
        addl(ir[2])
      when 'SUBA' then
        read_data(ir[2], memory)
        suba(ir[2])
      when 'SUBL' then
        read_data(ir[2], memory)
        subl(ir[2])
      when 'AND' then
        read_data(ir[2], memory)
        self.and(ir[2])
      when 'OR' then
        read_data(ir[2], memory)
        self.or(ir[2])
      when 'XOR' then
        read_data(ir[2], memory)
        xor(ir[2])
      when 'CPA' then
        read_data(ir[2], memory)
        cpa(ir[2])
      when 'CPL' then
        read_data(ir[2], memory)
        cpl(ir[2])
      when 'SLA' then
        read_data(ir[2], memory)
        sla(ir[2])
      when 'SRA' then
        read_data(ir[2], memory)
        sra(ir[2])
      when 'SLL' then
        read_data(ir[2], memory)
        sll(ir[2])
      when 'SRL' then
        read_data(ir[2], memory)
        srl(ir[2])
      when 'NOP' then
        self.nop
      when 'JPL' then
        jpl(ir[2], memory)
      when 'JMI' then
        jmi(ir[2], memory)
      when 'JNZ' then
        jnz(ir[2], memory)
      when 'JZE' then
        jze(ir[2], memory)
      when 'JOV' then
        jov(ir[2], memory)
      when 'JUMP' then
        jump(ir[2], memory)
      when 'CALL' then
        call(ir[2], memory)
      when 'RET' then
        ret(memory)
      when 'SVC' then
        self.svc

      # 擬似命令
      when 'START' then
        # 何もしない。プログラム開始の宣言。
      when 'END' then
        # 本来何もしない。プログラム終了の宣言。
        break
      when 'DC' then
        # 何もしない。メモリ上に定数を定義する宣言。
      when 'DS' then
        # 何もしない。メモリ上に領域を確保する宣言。

      # マクロ命令
      when 'IN' then
        # 入出力装置からデータを入力する。
      when 'OUT' then
        # 入出力装置へデータを入力する
      when 'RPUSH' then
        # 全てのレジスタの内容をスタックに退避する
      when 'RPOP' then
        # スタックの内容をレジスタに復帰する
      end
    end
  end

  # オペランドのアドレス計算、データの読み出し
  def read_data(operand, memory)
    operand.each_with_index do |o, i|
      unless /(^[0-9]+$|^gr[0-7]$)/.match(o)
        (0..49).each do |n|
          if !memory.send("m#{n}").nil? && memory.send("m#{n}")[0] == o
            operand[i] = memory.send("m#{n}")[2]
          end
        end
      end
    end
  end

  # 演算部

  # ------------------------------------------ #
  # 命令セット
  # ------------------------------------------ #

    # LD(Load)
    def ld(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        update_gr(operand[0], (operand[1].to_i + send("#{operand[2]}").to_i).to_s)
        p "#{operand[0]}に#{operand[1]}+#{operand[2]}のデータを読み込みました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        update_gr(operand[0], send("#{operand[1]}"))
        p "#{operand[0]}に#{operand[1]}のデータを読み込みました。"
      # オペランドが[GR,即値]の場合
      else
        update_gr(operand[0], operand[1])
        p "#{operand[0]}に#{operand[1]}を読み込みました。"
      end
    end

    # LAD(Load ADdress)
    def lad(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        update_gr(operand[0], (operand[1].to_i + send("#{operand[2]}").to_i).to_s)
        p "#{operand[0]}に#{operand[1]}+#{operand[2]}のデータを格納しました。"
      # オペランドが[GR,即値]の場合
      else
        update_gr(operand[0], operand[1])
        p "#{operand[0]}に#{operand[1]}を格納しました。"
      end
    end

    # POP
    def pop(operand, memory)
      update_gr(operand, memory.send("m#{self.sp}")[0])
      self.sp += 1
      p "#{operand}にスタックポインタのデータを読み込みました。"
    end

    # ST(STore)
    def st(operand, memory)
      # オペランドが[GR,アドレス]の場合
      if /^[0-9]+$/.match(operand[1])
        update_memory(operand[1], send("#{operand[0]}"), memory)
        p "m#{operand[1]}に#{operand[0]}のデータを格納しました。"
      # オペランドが[GR,ラベル]の場合
      else
        (0..49).each do |n|
          if !memory.send("m#{n}").nil? && memory.send("m#{n}")[0] == operand[1]
            update_memory(n.to_s, send("#{operand[0]}"), memory)
          end
        end
        p "#{operand[1]}に#{operand[0]}のデータを格納しました。"
      end
    end

    # PUSH
    def push(operand, memory)
      self.sp -= 1
      # オペランドが[アドレス]の場合
      if operand.length == 1
        update_memory(self.sp.to_s, operand[0], memory)
        p "スタック領域:m#{self.sp}に#{operand[0]}を格納しました。"
      # オペランドが[アドレス,GR]の場合
      else
        update_memory(self.sp.to_s, (operand[0].to_i + send("#{operand[1]}").to_i).to_s, memory)
        p "スタック領域:m#{self.sp}に#{operand[0]}+#{operand[1]}のデータを格納しました。"
      end
    end

    # ADDA
    def adda(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = arithmetic_logical_addition(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}+#{operand[2]}のデータを格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = arithmetic_logical_addition(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}のデータを格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = arithmetic_logical_addition(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}を格納しました。"
      end
    end

    # ADDL
    def addl(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = arithmetic_logical_addition(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}+#{operand[2]}のデータを格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = arithmetic_logical_addition(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}のデータを格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = arithmetic_logical_addition(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ+#{operand[1]}を格納しました。"
      end
    end

    # SUBA
    def suba(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = arithmetic_logical_subtraction(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}-#{operand[2]}のデータを格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = arithmetic_logical_subtraction(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}のデータを格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = arithmetic_logical_subtraction(array, 'arithmetic')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}を格納しました。"
      end
    end

    # SUBL
    def subl(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = arithmetic_logical_subtraction(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}-#{operand[2]}のデータを格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = arithmetic_logical_subtraction(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}のデータを格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = arithmetic_logical_subtraction(array, 'logical')
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータ-#{operand[1]}を格納しました。"
      end
    end

    # AND
    def and(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = logical_and(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}と#{operand[2]}のデータの論理積を格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = logical_and(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}のデータの論理積を格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = logical_and(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}の論理積を格納しました。"
      end
    end

    # OR
    def or(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = logical_or(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}と#{operand[2]}のデータの論理和を格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = logical_or(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}のデータの論理和を格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = logical_or(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}の論理和を格納しました。"
      end
    end

    # XOR
    def xor(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        answer = logical_xor(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}と#{operand[2]}のデータの排他的論理和を格納しました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        answer = logical_xor(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}のデータの排他的論理和を格納しました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        answer = logical_xor(array)
        update_gr(operand[0], answer)
        p "#{operand[0]}に#{operand[0]}のデータと#{operand[1]}の排他的論理和を格納しました。"
      end
    end

    # CPA
    def cpa(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        arithmetic_logical_comparison(array, 'arithmetic')
        p "#{operand[0]}のデータと#{operand[1]}+#{operand[2]}のデータの算術比較を行いました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        arithmetic_logical_comparison(array, 'arithmetic')
        p "#{operand[0]}のデータと#{operand[1]}のデータの算術比較を行いました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        arithmetic_logical_comparison(array, 'arithmetic')
        p "#{operand[0]}のデータと#{operand[1]}の算術比較を行いました。"
      end
    end

    # CPL
    def cpl(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        array = [send("#{operand[0]}"), operand[1], send("#{operand[2]}")]
        arithmetic_logical_comparison(array, 'logical')
        p "#{operand[0]}のデータと#{operand[1]}+#{operand[2]}のデータの論理比較を行いました。"
      # オペランドが[GR,GR]の場合
      elsif /^gr[0-7]$/.match(operand[1])
        array = [send("#{operand[0]}"), send("#{operand[1]}")]
        arithmetic_logical_comparison(array, 'logical')
        p "#{operand[0]}のデータと#{operand[1]}のデータの論理比較を行いました。"
      # オペランドが[GR,即値]の場合
      else
        array = [send("#{operand[0]}"), operand[1]]
        arithmetic_logical_comparison(array, 'logical')
        p "#{operand[0]}のデータと#{operand[1]}の論理比較を行いました。"
      end
    end

    # SLA
    def sla(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        update_gr(operand[0], send("#{operand[0]}").to_i << (operand[1].to_i + send("#{operand[2]}").to_i))
        p "#{operand[0]}のデータを#{operand[2]}のデータ+#{operand[1]} 左シフトしました。"
      # オペランドが[GR,即値]の場合
      else
        update_gr(operand[0], send("#{operand[0]}").to_i << operand[1].to_i)
        p "#{operand[0]}のデータを#{operand[1]} 左シフトしました。"
      end
    end

    # SLL
    def sll(operand)
      sla(operand)
    end

    # SRA
    def sra(operand)
      # オペランドが[GR,即値,GR]の場合
      if operand.length == 3
        update_gr(operand[0], send("#{operand[0]}").to_i >> (operand[1].to_i + send("#{operand[2]}").to_i))
        p "#{operand[0]}のデータを#{operand[2]}のデータ+#{operand[1]} 左シフトしました。"
      # オペランドが[GR,即値]の場合
      else
        update_gr(operand[0], send("#{operand[0]}").to_i >> operand[1].to_i)
        p "#{operand[0]}のデータを#{operand[1]} 左シフトしました。"
      end
    end

    # SRL
    def srl(operand)
      sra(operand)
    end

    # NOP
    def nop
      p "何もしませんでした。"
    end

    # JUMP
    def jump(operand, memory)
      # オペランドが[ラベル]の場合
      if operand.length == 1
        (0..49).each do |n|
          if memory.send("m#{n}")[0] == operand[0]
            self.pr = n
            p "PRを#{n}に変更しました。"
            break
          end
        end
      # オペランドが[即値,ラベル]の場合
      else
        self.pr = operand[0].to_i + send("#{operand[1]}").to_i
        p "PRを#{operand[0]}+#{operand[1]}のデータに変更しました。"
      end
    end

    # JPL
    def jpl(operand, memory)
      if self.fr[0] == 0 && self.fr[1] == 0
        jump(operand, memory)
      end
    end

    # JMI
    def jmi(operand, memory)
      if self.fr[1] == 1
        jump(operand, memory)
      end
    end

    # JNZ
    def jnz(operand, memory)
      if self.fr[0] == 0
        jump(operand, memory)
      end
    end

    # JZE
    def jze(operand, memory)
      if self.fr[0] == 1
        jump(operand, memory)
      end
    end

    # JOV
    def jov(operand, memory)
      if self.fr[2] == 1
        jump(operand, memory)
      end
    end

    # CALL
    def call(operand, memory)
      push([self.pr], memory)
      jump(operand, memory)
    end

    # RET
    def ret(memory)
      self.pr = memory.send("m#{self.sp}")[0].to_i
      self.sp += 1
    end

    # SVC
    def svc
      # ブラックボックス
    end

  # ------------------------------------------ #
  # 演算補助機能
  # ------------------------------------------ #

    # GRの更新
    def update_gr(name, value)
        instance_eval("self.#{name} = #{value}.to_s")
    end

    # FRの更新
    def update_fr(result, pattern)
      # サインフラグ
      if result < 0
        self.fr[1] = 1
      elsif pattern == 'arithmetic' && result > 32767
        self.fr[1] = 1
      end
      # オーバーフローフラグ
      if pattern == 'arithmetic' && result > 32767
        self.fr[2] = 1
        result -= 65536
      elsif pattern == 'arithmetic' && result < -32768
        self.fr[2] = 1
        result += 65536
      elsif pattern == 'logical' && result > 65535
        self.fr[2] = 1
        result -= 65536
      elsif pattern == 'logical' && result < 0
        self.fr[2] = 1
        result += 65536
      end
      # ゼロフラグ
      if result == 0
        self.fr[0] = 1
      end
      result
    end

    # memoryの更新
    def update_memory(address, value, memory)
      memory.instance_eval("self.m#{address}[-1] = #{value}.to_s")
    end

    # 算術論理加算
    def arithmetic_logical_addition(array, pattern)
      result = 0
      array.each do |a|
        a = a.to_i
        if pattern == 'arithmetic' && a > 32767
          a -= 65536
        elsif pattern == 'logical' && a < 0
          a += 65536
        end
        result += a
      end
      result = update_fr(result, pattern).to_s
    end

    # 算術論理減算
    def arithmetic_logical_subtraction(array,pattern)
      result = 0
      array.each_with_index do |a, i|
        a = a.to_i
        if pattern == 'arithmetic' && a > 32767
          a -= 65536
        elsif pattern == 'logical' && a < 0
          a += 65536
        end
        if i == 0
          result += a
        else
          result -= a
        end
      end
      result = update_fr(result, pattern).to_s
    end

    # 論理積算
    def logical_and(array)
      result = 65535
      array.each do |a|
        a = a.to_i
        if a > 32767
          a -= 65536
        end
        result &= a
      end
      result = update_fr(result, 'arithmetic').to_s
    end

    # 論理和算
    def logical_or(array)
      result = 0
      array.each do |a|
        a = a.to_i
        if a > 32767
          a -= 65536
        end
        result |= a
      end
      result = update_fr(result, 'arithmetic').to_s
    end

    # 排他的論理和算
    def logical_xor(array)
      result = 0
      array.each do |a|
        a = a.to_i
        if a > 32767
          a -= 65536
        end
        result ^= a
      end
      result = update_fr(result, 'arithmetic').to_s
    end

    # 算術論理比較
    def arithmetic_logical_comparison(array,pattern)
      array.each_with_index do |a, i|
        a = a.to_i
        if pattern == 'arithmetic' && a > 32767
          a -= 65536
        elsif pattern == 'logical' && a < 0
          a += 65536
        end
        array[i] = a
      end
      if array.length == 3
        if array[0] < array[1] + array[2]
          self.fr[1] = 1
        elsif array[0] == array[1] + array[2]
          self.fr[0] = 1
        end
      else
        if array[0] < array[1]
          self.fr[1] = 1
        elsif array[0] == array[1]
          self.fr[0] = 1
        end
      end
    end

end