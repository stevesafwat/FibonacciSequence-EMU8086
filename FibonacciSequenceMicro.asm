                                                                  .MODEL SMALL
.STACK 100h
.DATA
    promptMsg DB 'Enter the number of Fibonacci terms (1-25): $'
    resultMsg DB 13, 10, 'Fibonacci series:  $'
    invalidMsg DB 13, 10, 'Invalid input! $'
    newline DB 13, 10, '$'
    numTerms DB 0        ; To store the number of terms
    fib1 DW 0            ; First Fibonacci number (F1)
    fib2 DW 1            ; Second Fibonacci number (F2)
    fibNext DW 0         ; Next Fibonacci number
    count DB 0           ; Counter for terms printed

.CODE
main PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX

    ; Prompt user for number of Fibonacci terms
get_input:
    LEA DX, promptMsg
    MOV AH, 09h
    INT 21h

    ; Read number of terms (allow 1 to 25)
    CALL ReadNumber       ; Read two-digit input from the user
    MOV numTerms, AL      ; Store the number of terms in numTerms

    ; Validate input
    CMP numTerms, 1
    JB invalid_input       ; If less than 1, go to invalid_input
    CMP numTerms, 25
    JA invalid_input       ; If greater than 25, go to invalid_input

    ; Display result message
    LEA DX, resultMsg
    MOV AH, 09h
    INT 21h

    ; Print Fibonacci numbers based on user input
    MOV count, 0          ; Reset count of terms printed

print_fibonacci:
    ; Print the Fibonacci numbers until the specified count
    MOV AL, count         ; Load count into AL for comparison
    CMP AL, numTerms      ; Compare count with numTerms
    JGE done              ; If count >= numTerms, we're done

    ; Print the first Fibonacci number (F1 = 1)
    CMP count, 0
    JE print_first        ; If count is 0, print F1 (1)

    ; Print the second Fibonacci number (F2 = 1)
    CMP count, 1
    JE print_second       ; If count is 1, print F2 (1)

    ; Calculate next Fibonacci number
    MOV AX, fib1
    ADD AX, fib2          ; fibNext = fib1 + fib2
    MOV fibNext, AX

    ; Display the next Fibonacci number
    MOV AX, fibNext
    CALL PrintNumber

    ; Update fib1 and fib2
    MOV AX, fib2          ; Load fib2 into AX
    MOV fib1, AX          ; Store fib2 into fib1
    MOV AX, fibNext       ; Load fibNext into AX
    MOV fib2, AX          ; Store fibNext into fib2

    ; Increment the count of printed terms
    INC count
    JMP print_fibonacci   ; Repeat the loop

print_first:
    ; Print the first Fibonacci number (F1 = 1)
    MOV AX, fib1          ; F1 = 1
    CALL PrintNumber
    INC count             ; Increment count
    JMP print_fibonacci   ; Continue printing

print_second:
    ; Print the second Fibonacci number (F2 = 1)
    MOV AX, fib2          ; F2 = 1
    CALL PrintNumber
    INC count             ; Increment count
    JMP print_fibonacci   ; Continue printing

invalid_input:
    ; Display invalid input message
    LEA DX, invalidMsg
    MOV AH, 09h
    INT 21h
    JMP get_input         ; Prompt again for input

done:
    ; Exit program
    MOV AX, 4C00h
    INT 21h

; Subroutine to read two-digit decimal input
ReadNumber PROC
    MOV AH, 01h           ; Read first character
    INT 21h
    SUB AL, '0'           ; Convert first digit to integer
    MOV BL, AL            ; Store first digit in BL

    MOV AH, 01h           ; Read second character
    INT 21h
    CMP AL, '.'           ; Check if the character is a decimal point
    JE read_decimal       ; If it's a decimal point, go to read_decimal

    ; If there's no decimal point, process as two-digit integer
    SUB AL, '0'           ; Convert second digit to integer
    MOV BH, AL            ; Store second digit in BH
    MOV AL, BL            ; Combine both digits
    MOV BL, 10
    MUL BL                ; Multiply first digit by 10
    ADD AL, BH            ; Add second digit
    RET

read_decimal:
    ; Read the digit after the decimal point
    MOV AH, 01h
    INT 21h
    SUB AL, '0'           ; Convert to integer
    CMP AL, 5             ; Compare with 5 for rounding
    JL single_digit        ; If less than 5, round down

    ; If greater than or equal to 5, round up
    INC BL                ; Increment the whole number part

single_digit:
    MOV AL, BL            ; Move the rounded number into AL
    RET
ReadNumber ENDP

; Subroutine to print a number in AX
PrintNumber PROC
    ; Convert AX to ASCII (handle up to five digits for large Fibonacci numbers)
    XOR DX, DX            ; Clear DX to handle division
    MOV CX, 10            ; Base 10
    MOV BX, 0             ; Clear BX for digit count

convert_loop:
    XOR DX, DX            ; Clear DX before division
    DIV CX                ; Divide AX by 10, quotient in AX, remainder in DX
    PUSH DX               ; Store remainder on stack
    INC BX                ; Count the number of digits
    TEST AX, AX           ; Check if AX is zero
    JNZ convert_loop      ; Repeat if not zero

print_loop:
    POP DX                ; Get last digit
    ADD DL, '0'           ; Convert to ASCII
    MOV AH, 02h           ; Function to display a character
    INT 21h               ; Display character
    DEC BX                ; Decrement digit count
    JNZ print_loop        ; Repeat for all digits

    ; Print newline
    LEA DX, newline
    MOV AH, 09h
    INT 21h
    RET
PrintNumber ENDP

END main