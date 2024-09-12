; Kh?i t?o thanh ghi v?i d? li?u c?n ghi
LDI R16, 0xAA     ; Giá tr? c?n ghi
LDI YL, 0x00      ; Kh?i t?o con tr? Y v?i giá tr? th?p
LDI YH, 0x01      ; Kh?i t?o con tr? Y v?i giá tr? cao

; Kh?i t?o s? l?n l?p cho ??n khi ??a ch? 0x02FF (511 l?n)
LDI R17, 0x00     ; ??t giá tr? cao c?a R17 thành 0
LDI R18, 0x02     ; ??t giá tr? cao c?a R18 thành 2

LP:
    ST Y+, R16    ; L?u giá tr? c?a R16 vào ??a ch? mà Y tr? t?i, sau ?ó t?ng Y
    INC R17   ; T?ng giá tr? c?a R17 (R17 + 1)
    CPI R17, 0xFF ; So sánh giá tr? c?a R17 v?i 0xFF
    BRNE LP       ; N?u R17 ch?a ??t 0xFF, ti?p t?c l?p
    CPI R18, 0x02 ; So sánh giá tr? c?a R18 v?i 0x02
    BRNE LP       ; N?u R18 ch?a ??t 0x02, ti?p t?c l?p

END: 
    RJMP END      ; K?t thúc ch??ng trình và nh?y ??n chính nó
