#!/usr/bin/awk -f
# TSV → xlsx sheet XML 转换器(C 编译的 awk, 比 Python 快 10 倍)
#
# Usage:
#   awk -f tsv_to_xlsx.awk -v MAX_ROWS=1000000 -v SHEET_PREFIX="Data" < input.tsv > output.txt
#
# 输出格式: 每行一条指令, Python 读取后分发到不同 sheet XML 文件
#   SHEET_START:<sheet_name>      → 新建 sheet XML 文件
#   <xml content>                → 写入当前 sheet
#   SHEET_END                    → 关闭当前 sheet
#
# 输入: mysql --batch 的 TSV (第一行是列名)

BEGIN {
    FS = "\t"
    MAX_ROWS = (MAX_ROWS + 0 > 0) ? MAX_ROWS + 0 : 1000000
    SHEET_PREFIX = (SHEET_PREFIX != "") ? SHEET_PREFIX : "Data"
    sheet_num = 0
    row_in_sheet = 0
    global_row = 0
    num_cols = 0
}

# 第一行: mysql 列名表头
NR == 1 {
    num_cols = NF
    col_labels = ""
    for (i = 1; i <= NF; i++) {
        val = $i
        gsub(/&/, "\\&amp;", val)
        gsub(/</, "\\&lt;", val)
        gsub(/>/, "\\&gt;", val)
        col_labels = col_labels "<c t=\"inlineStr\"><is><t>" val "</t></is></c>"
    }
    next
}

# 数据行
{
    if (row_in_sheet == 0) {
        sheet_num++
        sheet_name = (sheet_num == 1) ? SHEET_PREFIX : SHEET_PREFIX "_" sheet_num
        print "SHEET_START:" sheet_name
        # 写表头
        print "<row r=\"1\">" col_labels "</row>"
        row_in_sheet = 1
    }

    row_in_sheet++
    global_row++
    row_num = row_in_sheet

    line = "<row r=\"" row_num "\">"
    for (i = 1; i <= num_cols; i++) {
        val = $i
        # 判断数值
        if (val ~ /^-?[0-9]+$/) {
            # 整数
            line = line "<c><v>" val "</v></c>"
        } else if (val ~ /^-?[0-9]+\.?[0-9]+$/) {
            # 浮点
            line = line "<c><v>" val "</v></c>"
        } else if (val == "" || val == "NULL" || val == "\\N") {
            line = line "<c/>"
        } else {
            # 字符串, XML 转义
            gsub(/&/, "\\&amp;", val)
            gsub(/</, "\\&lt;", val)
            gsub(/>/, "\\&gt;", val)
            line = line "<c t=\"inlineStr\"><is><t>" val "</t></is></c>"
        }
    }
    line = line "</row>"
    print line

    if (row_in_sheet >= MAX_ROWS) {
        print "SHEET_END"
        row_in_sheet = 0
    }
}

END {
    if (row_in_sheet > 0) {
        print "SHEET_END"
    }
    print "DONE:" global_row
}
