require './lib/cpu'
require './lib/memory'

memory = Memory.new
cpu = CPU.new

# 例①加算結果を取得する
#              ラベル    オペコード　オペランド
memory.m0 =   ['',      'START'                   ]
memory.m1 =   ['',      'LD',     ['gr0','A']     ] # GR0にAの値を格納
memory.m2 =   ['',      'LD',     ['gr1','B']     ] # GR1にBの値を格納
memory.m3 =   ['',      'ADDA',   ['gr0','gr1']   ] # GR0とGR1の値を加算
memory.m4 =   ['',      'ST',     ['gr0','ANS']   ] # GR0の値をANSに格納
memory.m5 =   ['A',     'DC',     '123'           ] # 定数Aを定義
memory.m6 =   ['B',     'DC',     '456'           ] # 定数Bを定義
memory.m7 =   ['ANS',   'DS',     '1'             ] # 領域ANSを確保
memory.m8 =   ['',      'END'                     ]


# 例②絶対値を取得する（条件分岐）
#              ラベル    オペコード　オペランド
# memory.m0 =   ['ABS',   'START'                   ]
# memory.m1 =   ['',      'LAD',    ['gr0','0']     ] # GR0に0を格納
# memory.m2 =   ['',      'LD',     ['gr1','A']     ] # GR1にAの値を格納
# memory.m3 =   ['',      'CPA',    ['gr0','gr1']   ] # GR0とGR1を比較
# memory.m4 =   ['',      'JMI',    ['LABEL']       ] # GR0 < GR1ならLABELへジャンプ
# memory.m5 =   ['',      'XOR',    ['gr1','65535'] ] # GR1のビットの並びを反転
# memory.m6 =   ['',      'ADDA',   ['gr1','1']     ] # GR1の値に1を加算
# memory.m7 =   ['LABEL', 'ST',     ['gr1','ANS']   ] # GR1の値をANSに格納
# memory.m8 =   ['A',     'DC',     '-123'          ] # 定数Aを定義
# memory.m9 =   ['ANS',   'DS',     '1'             ] # 領域ANSを確保
# memory.m10 =  ['',      'END'                     ]


# 例③1からNUMまでの合計を求める（繰返処理）
#              ラベル    オペコード　オペランド
# memory.m0 =   ['SUM',   'START'                   ]
# memory.m1 =   ['',      'LAD',    ['gr0','0']     ] # 0をGR0に格納
# memory.m2 =   ['',      'LAD',    ['gr1','0']     ] # 0をGR1に格納
# memory.m3 =   ['LABEL1','ADDA',   ['gr0','1']     ] # GR0に1を加算
# memory.m4 =   ['',      'CPA',    ['gr0','NUM']   ] # GR0とNUMを算術比較
# memory.m5 =   ['',      'JPL',    ['LABEL2']      ] # GR0 > NUM の場合LABEL2にジャンプ
# memory.m6 =   ['',      'ADDA',   ['gr1','gr0']   ] # GR1にGR0を加算
# memory.m7 =   ['',      'JUMP',   ['LABEL1']      ] # 無条件にLABEL1へジャンプ
# memory.m8 =   ['LABEL2','ST',     ['gr1','ANS']   ] # ANSにGR1を格納
# memory.m9 =   ['NUM',   'DC',     '3'             ] # 定数NUMを定義
# memory.m10 =  ['ANS',   'DS',     '1'             ] # 領域ANSを確保
# memory.m11 =  ['',      'END'                     ]


# 例④平均値を取得する（サブルーチン）
#              ラベル    オペコード　オペランド
# memory.m0 =   ['MAIN',  'START'                   ] # メインルーチンの先頭
# memory.m1 =   ['',      'LD',     ['gr0','DATA1'] ] # DATA1をGR0に格納
# memory.m2 =   ['',      'LD',     ['gr1','DATA2'] ] # DATA2をGR1に格納
# memory.m3 =   ['',      'CALL',   ['SUB']         ] # サブルーチン呼出
# memory.m4 =   ['',      'ST',     ['gr0','AVE']   ] # 処理結果をAVEに格納
# memory.m5 =   ['DATA1', 'DC',     '100'           ] # 定数DATA1を定義
# memory.m6 =   ['DATA2', 'DC',     '200'           ] # 定数DATA2を定義
# memory.m7 =   ['AVE',   'DS',     '1'             ] # 領域AVEを確保
# memory.m8 =   ['',      'END'                     ] # メインルーチンの末尾
# memory.m9 =   ['SUB',   'START'                   ] # サブルーチンの先頭
# memory.m10 =  ['',      'ADDA',   ['gr0','gr1']   ] # GR0とGR1を加算しGR0に格納
# memory.m11 =  ['',      'SRA',    ['gr0','1']     ] # GR0を1ビット右シフト(1/2にする)
# memory.m12 =  ['',      'RET'                     ] # メインルーチンに戻る
# memory.m13 =  ['',      'END'                     ] # サブルーチンの末尾

# m40-m49をスタック領域として確保
memory.m40 =  ['']
memory.m41 =  ['']
memory.m42 =  ['']
memory.m43 =  ['']
memory.m44 =  ['']
memory.m45 =  ['']
memory.m46 =  ['']
memory.m47 =  ['']
memory.m48 =  ['']
memory.m49 =  ['']

cpu.control(memory)

puts "参考：memory7の状況 #{memory.m7}"