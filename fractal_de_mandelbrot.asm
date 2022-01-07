; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent
extern XDrawPoint

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit
extern scanf

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

section .bss
display_name:	resq	1
screen:			resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1
image_x: resd 1
image_y: resd 1
z_r: resd 1
z_i: resd 1
i: resd 1 
c_r: resd 1
c_i: resd 1
tmp: resd 1
x: resd 1
y: resd 1
color: resd 1
zoom2: resb 1




section .data
one: db 1 
event:		times	24 dq 0
format: db "%hhd%",0
message: db "voulez-vous zoomer oui (1) / non (0) ? ",10,0
x1:	dd	-2.1
x2:	dd	0.6
y1:	dd	-1.7
y2:	dd      1.7
iteration_max:  dd   50

four: dd 4.0
two: dd 2.0
zoom_1: dd 100.0
zoom_3: dd 200.0
zoom: dd 100.0
zero: db 0
un: dd 1

section .text
	
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
   push rbp

                                    
display:   
                                                     
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x000000
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x0000FF	; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je closeDisplay						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
dessin:

 ;**************calcule de image_x*************** 
movss xmm0,dword[x2]                                ; xmm0 = x2                              
subss xmm0,dword[x1]                                ; xmm0 == x2 - x1           
 mulss xmm0,dword[zoom]                             ; xmm0 = (x2 - x1) / zoom                                               
cvtss2si eax,xmm0                                   ; en transforme le résultatas a un nombre entier
mov dword[image_x],eax                              ; image_x = (x2 - x1) / zoom


;*********calcule de image_y********************

movss xmm2,dword[y2]                            ;xmm2 = x2               
subss xmm2,dword[y1]                            ;xmm2 = x2 - x1               
mulss xmm2,dword[zoom]                          ;xmm2 = (x2 - x1) /zoom                                                           
cvtss2si eax,xmm2                               ; en transforme le résultatas a un nombre entier
mov dword[image_y],eax                          ;image_y = (x2-x1) / zoom


mov dword[x],0                                  ; x = 0               


boucle1:       ;***************** for(x = 0 ; x < image_x ; x++)

                                                 

    mov dword[y],0                                   ; y = 0        

        boucle2:       ;******************** for ( y = 0 ; y < image_y ; y++)
        
                                        
    
             ; c_r = x / zoom + x1
           mov eax,dword[x]
           cvtsi2ss xmm0,eax
           divss xmm0,dword[zoom]
           addss xmm0,dword[x1]
           movss dword[c_r],xmm0
           
           mov eax,dword[y]
          
           cvtsi2ss xmm1,eax
           divss xmm1,dword[zoom]
           addss xmm1,dword[y1]
           movss dword[c_i],xmm1
            
           
             ; c_i = x / zoom + y1                      
            
            mov dword[z_r],0                ; z_r = 0         
            mov dword[z_i],0                ; z_i = 0                      
            mov dword[i],0                  ; i = 0                    
                                        
      
    
                            while:        ; boucle while                       
                            movss xmm0,dword[z_r]
                            movss dword[tmp],xmm0                    ;tmp = z_r            
                                        
                            movss xmm1,[z_r]
                            mulss xmm1,xmm1                    
                            movss xmm2,dword[z_i]
                            mulss xmm2,xmm2                           ;z_r = z_r*z_r - z_i*z_i + c_r                           
                            subss xmm1,xmm2                     
                            addss xmm1,dword[c_r]              
                            movss dword[z_r],xmm1              
                            
                            
                            movss xmm3,dword[z_i]
                            mulss xmm3,dword[two]
                            mulss xmm3,dword[tmp]                   ;z_i = 2*z_i*tmp + c_i
                            addss xmm3,dword[c_i]
                            movss dword[z_i],xmm3
                            
                            inc dword[i]                             ; i++
                            
                            movss xmm4,dword[z_r]
                            movss xmm5,dword[z_i]
                            mulss xmm4,xmm4
                            mulss xmm5,xmm5                         ;  e z_r*z_r + z_i*z_i
                            addss xmm4,xmm5 
                            
                            ucomiss xmm4,dword[four]                ; comparaison avec 4.0
                            jae draw                                 ; xmm4 >= on passe au dessin
                           
                         
                            
                            
                            mov eax,dword[iteration_max]          
                            
                            cmp dword[i],eax                     ; on compare i avec iteration max
                            
                            jb while                             ;  i< iteration_max ---> while
                            
                            draw:
                            mov eax,dword[i]
                            cmp eax,dword[iteration_max]
                            jne drawcolor                         ; i != iteration_max --> on dessine (x,y) en couleur                             
                            mov rdi, qword[display_name]          ; else on dessine (x,y) on noir 
                            mov rsi, qword[gc]
                            mov edx, 0x000000                      ; couleur noir
                            call XSetForeground 
                           
                      
                         
                            mov rdi,qword[display_name]
                            mov rsi,qword[window]
                            mov rdx,qword[gc]                               ; dessin des pixel (x,y)
                            mov ecx,dword[x] ; 
                            mov r8d,dword[y] ;
                            mov r9d,dword[x] ;
                            push qword[y] ; 
                            call XDrawPoint
                            jmp for

                            
                 drawcolor:
                 mov eax, 255
                 mul dword[i]
                 div dword[iteration_max]               ; (color = i*255) / iteration_max
                 mov dword[color],eax
                  mov rdi, qword[display_name]
                            mov rsi, qword[gc]
                            
                                                    ; la mise de la couleur
                           
                           mov edx,[color]
                           
                            
                            
                            
                           
                            call XSetForeground 
                           
                         
                            mov rdi,qword[display_name]
                            mov rsi,qword[window]
                            mov rdx,qword[gc]
                            mov ecx,dword[x] ; 
                            mov r8d,dword[y] ; 
                            mov r9d,dword[x] ; 
                            push qword[y] ; 
                            call XDrawPoint
                            mov eax,dword[i]

                            for:                    
    
                        ;condition de sortire de la boucle
inc dword[y]        ; y++
mov eax,dword[y]
cmp eax,dword[image_y]
jb boucle2              ; y< image_y  ---> boucle2

inc dword[x]            ; x ++
mov eax,dword[x]
cmp eax,dword[image_x]
jb boucle1               ; x < image_x ----> boucle1
                    





; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
    pop rbp
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
    

