; Kh?i t?o thanh ghi v?i d? li?u c?n ghi
LDI R16, 0xAA     ; Gi� tr? c?n ghi
LDI YL, 0x00      ; Kh?i t?o con tr? Y v?i gi� tr? th?p
LDI YH, 0x01      ; Kh?i t?o con tr? Y v?i gi� tr? cao

; Kh?i t?o s? l?n l?p cho ??n khi ??a ch? 0x02FF (511 l?n)
LDI R17, 0x00     ; ??t gi� tr? cao c?a R17 th�nh 0
LDI R18, 0x02     ; ??t gi� tr? cao c?a R18 th�nh 2

LP:
    ST Y+, R16    ; L?u gi� tr? c?a R16 v�o ??a ch? m� Y tr? t?i, sau ?� t?ng Y
    INC R17   ; T?ng gi� tr? c?a R17 (R17 + 1)
    CPI R17, 0xFF ; So s�nh gi� tr? c?a R17 v?i 0xFF
    BRNE LP       ; N?u R17 ch?a ??t 0xFF, ti?p t?c l?p
    CPI R18, 0x02 ; So s�nh gi� tr? c?a R18 v?i 0x02
    BRNE LP       ; N?u R18 ch?a ??t 0x02, ti?p t?c l?p

END: 
    RJMP END      ; K?t th�c ch??ng tr�nh v� nh?y ??n ch�nh n�
