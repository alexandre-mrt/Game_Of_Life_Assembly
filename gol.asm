;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:

	addi sp, zero, CUSTOM_VAR_END
	while_true:
		addi  sp, sp, -4
		stw ra, 0(sp)
		call reset_game
		ldw ra, 0(sp)
		addi sp, sp, 4

		addi  sp, sp, -4
		stw ra, 0(sp)
		call get_input
		ldw ra, 0(sp)
		addi sp, sp, 4
		
		add a3, v0, zero
		
		add bt, zero, zero
		
		while_not_done:

			add a0, a3, zero
			call select_action

			add a0, a3, zero
			call update_state

			call update_gsa

			call mask

			call draw_gsa

			call wait
	
			call decrement_step
			
			add bt, v0, zero

			call get_input

			add a3, v0, zero

			beq bt, zero, while_not_done

		br while_true

			
		
	; BEGIN:clear_leds
	clear_leds:
		; your implementation code
		
		addi t1, zero, 4
		addi t2, zero, 8
		
		stw zero, LEDS (zero)
		stw zero, LEDS (t1)
		stw zero, LEDS (t2)
		
		ret
	; END:clear_leds


	; BEGIN:set_pixel
	set_pixel:
		; your implementation code
		add t0, zero, a0

		cmpgei t1, a0, 8

		slli t1, t1, 3

		cmpgei t2, a0, 4

		slli t2, t2, 2

		cmpge t3, t1, t2
		cmpge t4, t2, t1
		
		sub t3, zero, t3
		sub t4, zero, t4

		and t1, t1, t3
		and t2, t2, t4

		sub t0, t0, t1
		sub t0, t0, t2
		
		add t5, t1, t2
		ldw t6, LEDS (t5)

		addi t1, zero, 8
		addi t2, zero, 1
 
		slli t0, t0, 3
		add t0, t0, a1

		sll t2, t2, t0
		or t6, t6, t2
		
		stw t6, LEDS (t5)
		
		ret
	; END:set_pixel

	; BEGIN:wait
	wait:
		; your implementation code
        
		addi t0, zero, 2
		slli t0, t0, 19
        ldw t2, SPEED(zero)

		wait_loop:
			sub t0, t0, t2
			bge t0, zero, wait_loop

		wait_end:
			ret
	; END:wait

	; BEGIN:get_gsa
	get_gsa:
		; your implementation code
		slli t1, a0, 2

		ldw t0, GSA_ID (zero)
		beq t0, zero, get_gsa0
		bne t0, zero , get_gsa1

		get_gsa0:
			ldw v0, GSA0 (t1)
			br get_gsa_end
		
		get_gsa1:
			ldw v0, GSA1 (t1)
			br get_gsa_end

		get_gsa_end:
			ret  
	; END:get_gsa

	; BEGIN:set_gsa
	set_gsa:
		; your implementation code

		slli t1, a1, 2
		ldw t0, GSA_ID (zero)
		beq t0, zero, set_gsa0
		bne t0, zero, set_gsa1 
		
		set_gsa0:
			stw a0, GSA0 (t1)
			br set_gsa_end
		
		set_gsa1:
			stw a0, GSA1 (t1)
			br set_gsa_end
		
		set_gsa_end:
			ret  
	; END:set_gsa

	; BEGIN:draw_gsa
	draw_gsa:
		; your implementation code
		addi    sp, sp, -4   
        stw     ra, 0(sp)

        add	    s0, zero, zero
        add	    s1, zero, zero
        add	    s2,	zero, zero

		addi	s3, zero, 8

		br gsa_over_line

        gsa_over_line:
        	addi	s3, s3, -1

       		add     a0, zero, s3
        	call    get_gsa
        	add     t1, v0, zero
        
       		addi	t2, zero, 12

        gsa_over_element:
        	addi 	t2, t2, -1

        	addi    t3, zero, 1
        	sll     t3, t3, t2
        	and		t3, t1, t3
        	beq		t3, zero, next_iteration

        	addi    t3, zero, 31
        	slli    t4, t2, 3
        	add     t4, s3, t4
        	and     t5, t4, t3
        	srli    t6, t4, 5

        	addi    t3, zero, 1
        	blt	    t6, t3, set_led_one
        	addi    t3, zero, 2
        	blt     t6, t3, set_led_two
        	br		set_led_three

		set_led_one:
        	addi    t4, zero, 1
        	sll     t4, t4, t5
        	or      s0, s0, t4
        	br      next_iteration
        
        set_led_two:
        	addi    t4, zero, 1
        	sll     t4, t4, t5
        	or      s1, s1, t4
        	br      next_iteration

        set_led_three:
        	addi    t4, zero, 1
        	sll     t4, t4, t5
        	or      s2, s2, t4
        	br      next_iteration

        next_iteration:
        	bne     t2, zero, gsa_over_element
        	bne     s3, zero, gsa_over_line 
			br draw_gsa_end

		draw_gsa_end:
			stw s0, LEDS(zero)
        	stw s1, 4+LEDS(zero)
        	stw s2, 8+LEDS(zero)

        	ldw ra, 0(sp)
        	addi sp, sp, 4

        	ret

	; END:draw_gsa
	
	; BEGIN:random_gsa
	random_gsa:
		; your implementation code

		addi s3, zero, N_GSA_LINES
		addi s4, zero, N_GSA_COLUMNS
        addi s1, zero, -1

        random_gsa_over_lines:           
        	addi s1, s1, 1

       		add t1, zero, zero     

        	addi s0, zero, -1
        
		random_gsa_over_elements:       
        	addi s0, s0 ,1

        	ldw t2, RANDOM_NUM(zero)
        	addi t3, zero, 1
        	and t2, t2, t3

        	beq t2, zero, set_random_pixel  

        	sll t3, t3, s0
        	or t1, t1, t3
        
			set_random_pixel:
        		bne s0, s4, random_gsa_over_elements

        		add a0, zero, t1
        		add a1, zero, s1

				addi sp, sp, -4      
        		stw ra, 0(sp)
        		call set_gsa     
				ldw ra, 0(sp)
				addi sp, sp, 4  
       
        		bne s1, s3, random_gsa_over_lines 

        ret
	; END:random_gsa

	; BEGIN:change_speed
	change_speed:
		; your implementation code
		ldw t0, SPEED (zero)
		addi t1, zero, MIN_SPEED
		addi t2, zero, MAX_SPEED
		bne a0, zero, decrease_gamespeed
		beq a0, zero, increase_gamespeed

		decrease_gamespeed:
			beq t0, t1, change_speed_end
			addi t0, t0, -1
			br change_speed_end
		
		increase_gamespeed:
			beq t0, t2, change_speed_end
			addi t0, t0, 1
			br change_speed_end
		
		change_speed_end:
			stw t0, SPEED(zero)
			ret
	; END:change_speed


	; BEGIN:pause_game
	pause_game:
		; your implementation code
		ldw t0, PAUSE (zero)
		addi t1, zero, PAUSED
		addi t2, zero, RUNNING

		beq t0, t1, resume_action
		beq t0, t2, pause_action
		
		br pause_end
		
		pause_action:
			stw t1, PAUSE (zero)
			br pause_end
		
		resume_action:
			stw t2, PAUSE (zero)
			br pause_end

		pause_end:
			ret
	; END:pause_game
	

	; BEGIN:change_steps
	change_steps:
		; your implementation code
		ldw t0, CURR_STEP (zero)
		
		change_button4:
			beq a0, zero, change_button3
			addi t0, t0, 1
		
		change_button3:
			beq a1, zero, change_button2
			addi t0, t0, 16
		
		change_button2:
			beq a2, zero, change_steps_end
			addi t0, t0, 256
		
		change_steps_end:
			stw t0, CURR_STEP (zero)
			ret
	; END:change_steps

	; BEGIN:increment_seed
	increment_seed:
		; your implementation code
		ldw t4, SEED (zero)
		ldw t1, CURR_STATE (zero)
		
		addi t2, zero, INIT
		addi t3, zero, RAND

		beq t1, t2, increment_seed_init
		beq t1, t3, increment_seed_rand
		br increment_seed_end	
		
		increment_seed_init:
            addi t5, zero, N_SEEDS
            beq t4, t5, increment_seed_rand ; si seed == 4 on augmente pas 
			addi t4, t4, 1
			stw t4, SEED (zero)
            beq t4, t5, increment_seed_rand ; si apres modif on envoie une rand seed selon post ed

			slli t4, t4, 2
			ldw t4, SEEDS (t4)
		
			add a0, zero, zero
			add a1, zero, zero
			
			br loop

			loop:
				ldw a0, 0 (t4)
				addi t4, t4, 4

                addi  sp, sp, -12
				stw a1, 8(sp)
				stw t4, 4(sp)
		        stw ra, 0(sp)
		        call set_gsa
		        ldw  ra, 0(sp)
				ldw t4, 4(sp)
				ldw a1, 8(sp)
		        addi sp,sp, 12
				

				addi a1, a1, 1
				addi t5, zero, N_GSA_LINES
				bne a1, t5, loop
				br increment_seed_end	
		
		increment_seed_rand:
			addi t4, zero, 4
			stw t4, SEED (zero)

            addi  sp, sp, -8
			stw t4, 4(sp)
		    stw ra, 0(sp)
		    call random_gsa	
		    ldw  ra, 0(sp)
			ldw t4, 4(sp)
		    addi sp,sp, 8

			br increment_seed_end	

		increment_seed_end:
        	ret
	; END:increment_seed

	; BEGIN:update_state	
	update_state:
		; your implementation code

		ldw t0, CURR_STATE (zero)
		addi t1, zero, INIT
		addi t2, zero, RAND
		addi t3, zero, RUN

		add t4, a0, zero ; pourquoi pas laisser a0

		beq t0, t1, update_state_init
		beq t0, t2, update_state_rand
		beq t0, t3, update_state_run
		br update_state_end

		update_state_init:
			andi t7, t4, 2
            bne t7, zero, update_state_init_run
            ldw t5, SEED(zero)
            addi t6, zero, N_SEEDS
            beq t6, t5, update_state_init_rand 
			br update_state_end
			
			update_state_init_rand:
				stw t2, CURR_STATE(zero)
				jmpi update_state_end

			update_state_init_run:
				stw t3, CURR_STATE(zero)
                addi t0, zero, 1
                stw t0, PAUSE (zero) ;update pause to running
				jmpi update_state_end

		update_state_rand:
			andi t4, t4, 2
			beq t4, zero, update_state_end
			
			stw t3, CURR_STATE(zero)
            addi t0, zero, 1
            stw t0, PAUSE (zero) ;update pause to running
			jmpi update_state_end

		update_state_run:
			andi t7, t4, 8
			bne t7, zero, update_state_run_reset

			br update_state_end
			
			update_state_run_random:
				stw t2, CURR_STATE(zero)
				jmpi update_state_end
			
			update_state_run_reset:
				addi  sp, sp, -4
		        stw ra, 0(sp)
		        call reset_game
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				addi t1, zero, INIT
                stw t1, CURR_STATE(zero)
                br update_state_end
		
		update_state_end:	
			ret
	; END:update_state

	; BEGIN:reset_game
	reset_game:
		; your implementation code
		
 		addi  sp, sp, -4
		stw ra, 0(sp)
		call clear_leds
        ldw  ra, 0(sp)
		addi sp,sp, 4

		addi t0, zero, 1
		stw t0, CURR_STEP(zero)


		display_step:

			ldw s0, font_data(zero)
			addi s1, zero, 1
			slli s1, s1 , 2

			addi s1, s1, font_data
			ldw s1, 0(s1)

			stw s0, SEVEN_SEGS(zero)
			stw s0, 4+SEVEN_SEGS(zero)
			stw s0, 8+SEVEN_SEGS(zero)
			stw s1, 12+SEVEN_SEGS(zero)

		stw zero, SEED(zero)
		
		ldw t0, SEEDS (zero)
		
		add s0, zero, zero
		add s1, zero, zero

		loop_seed_reset:

			ldw s0, 0 (t0)
			addi t0, t0, 4
			stw s0, GSA0 (s1)
			addi s1, s1, 4
			
			addi t1, zero, N_GSA_LINES
			slli t1, t1, 2
			bne s1, t1, loop_seed_reset


		stw zero, GSA_ID(zero)

		addi  sp, sp, -4
		stw ra, 0(sp)
		call draw_gsa
        ldw  ra, 0(sp)
		addi sp,sp, 4

		
		stw zero, PAUSE(zero)

		stw zero, CURR_STATE(zero)

		addi t0, zero, MIN_SPEED

		stw t0, SPEED(zero)

		add a0, zero, zero
		add a1, zero, zero

		ret
	; END:reset_game


	; BEGIN:select_action
	select_action:
		; your implementation code

		ldw t0, CURR_STATE (zero)
		addi t1, zero, INIT
		addi t2, zero, RAND
		addi t3, zero, RUN

		add t4, a0, zero
		beq t0, t1, select_action_init
		beq t0, t2, select_action_rand
		beq t0, t3, select_action_run
		br select_action_end
		
		select_action_init:

			beq t4, zero, select_action_end
		
			andi t1, t4, 2
			bne t1, zero, select_action_end

			andi t1, t4, 1
			bne t1, zero, select_action_init_buttonzero
		
			bne t4, zero, select_action_init_otherbutton_pressed

			br select_action_end
	
			select_action_init_buttonzero:
				
				addi  sp, sp, -4
		        stw ra, 0(sp)
		        call increment_seed
		        ldw  ra, 0(sp)
		        addi sp,sp, 4

				
				br select_action_end
	

			select_action_init_otherbutton_pressed:
				andi a0, t4, 16
				andi a1, t4, 8
				andi a2, t4, 4

				cmpne a0, a0, zero
				cmpne a1, a1, zero
				cmpne a2, a2, zero
				
                addi  sp, sp, -4
		        stw ra, 0(sp)
		        call change_steps
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end

			

		select_action_rand:
			andi t1, t4, 1
			bne t1, zero, select_action_rand_buttonzero_pressed
		
			andi t1, t4, 2
			bne t1, zero, select_action_end

			andi t1, t4, 4
			andi t2, t4, 8
			andi t3, t4, 16

			
			or t0, t1, t2
			or t0, t0, t3
			bne t0, zero, select_action_rand_otherbutton_pressed

			br select_action_end
			
			select_action_rand_buttonzero_pressed:

                addi  sp, sp, -4
		        stw ra, 0(sp)
		        call random_gsa
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end

			select_action_rand_otherbutton_pressed:
				add a0, zero, t3
				add a1, zero, t2
				add a2, zero, t1

				cmpne a0, a0, zero
				cmpne a1, a1, zero
				cmpne a2, a2, zero


                addi  sp, sp, -4
		        stw ra, 0(sp)
		        call change_steps
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end
			
	
		select_action_run:

			andi t1, t4, 1
			bne t1, zero, select_action_run_buttonzero_pressed
		
			andi t1, t4, 2
			bne t1, zero, select_action_run_buttonone_pressed

			andi t1, t4, 4
			bne t1, zero, select_action_run_buttontwo_pressed

			andi t1, t4, 8
			bne t1, zero, select_action_end

			andi t1, t4, 16
			bne t1, zero, select_action_run_buttonfour_pressed

			br select_action_end

			select_action_run_buttonzero_pressed:

                addi  sp, sp, -4
		        stw ra, 0(sp)
		        call pause_game
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end

			select_action_run_buttonone_pressed:
				add a0, zero, zero

                addi  sp, sp, -4
		        stw ra, 0(sp)
		        call change_speed
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end
		
			select_action_run_buttontwo_pressed:
				addi a0, zero, 1

				addi  sp, sp, -4
		        stw ra, 0(sp)
		        call change_speed
		        ldw  ra, 0(sp)
		        addi sp,sp, 4
				
				br select_action_end

			select_action_run_buttonfour_pressed:
				addi  sp, sp, -4
		        stw ra, 0(sp)
		        call random_gsa
		        ldw  ra, 0(sp)
		        addi sp,sp, 4

				br select_action_end

		select_action_end:
			ret
    ; END:select_action

	; BEGIN:cell_fate
    cell_fate:

        bne     a1, zero, living_cell_fate
        addi    t0, zero, 3
        bne     a0, t0, dead_cell_fate
        addi    v0, zero, 1

        living_cell_fate:
        	addi    t0, zero,   2
        	addi    t1, zero,   4
        	blt     a0, t0, dead_cell_fate
        	bge     a0, t1, dead_cell_fate
        	addi    v0, zero, 1
        	br      cell_fate_end

		dead_cell_fate:  
        	add v0, zero, zero    
        	br cell_fate_end
        
		cell_fate_end:
    	    ret
    ; END:cell_fate

	
	; BEGIN:find_neighbours
	find_neighbours:
		; your implementation code
		add v0, zero, zero
		add t0, zero, a0
		add t1, zero, a1
		

		addi a0, t0, 1
		addi a1, t1, 1	
		
		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, a1, 7


        addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		
		add v0, v0, v1

		addi a0, t0, 1
		add a1, t1, zero

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, t1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		addi a1, t1, 1
		add a0, t0, zero

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, a1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		addi a0, t0, -1
		addi a1, t1, -1

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, a1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		
		add v0, v0, v1

		addi a0, t0, -1
		add a1, t1, zero

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, t1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		addi a1, t1, -1
		add a0, t0, zero

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, a1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		addi a0, t0, -1
		addi a1, t1, 1

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		andi a1, a1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		addi a0, t0, 1
		addi a1, t1, -1
		
		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_modulo_twelve
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12
		andi a1, a1, 7

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi  sp, sp, 12

		add v0, v0, v1

		add a0, zero, t0
		add a1, zero, t1

		addi  sp, sp, -12
		stw t1, 8(sp)
		stw t0, 4(sp)
	    stw ra, 0(sp)
		call get_pixel
		ldw ra, 0(sp)
		ldw t0, 4(sp)
		ldw t1, 8(sp)
		addi sp, sp, 12
		
		ret
		
		get_pixel:

			add t0, zero, a0

			cmpgei t1, t0, 8
			bne t1, zero, get_pixel_x_greater_than_eight

			cmpgei t1, t0, 4
			bne t1, zero, get_pixel_x_greater_than_four
 			
			br get_pixel_x_greater_than_zero

			get_pixel_x_greater_than_zero:

				ldw t1, LEDS (zero)
				br get_pixel_y

			get_pixel_x_greater_than_four:

				ldw t1, 4 + LEDS (zero)
				br get_pixel_y

			get_pixel_x_greater_than_eight:
				ldw t1, 8 + LEDS (zero)
				br get_pixel_y

			get_pixel_y:

				andi t0, t0, 3
				slli t0, t0, 3
				add t0, t0, a1
				addi t2, zero, 1
				
				sll t2, t2, t0
				
				and t1, t1, t2

				cmpne v1, t1, zero
				br get_pixel_end

			get_pixel_end:
				ret

		get_modulo_twelve:
			addi t1, a0, -12
			blt t1, zero, end_get_modulo_twelve
			add a0, zero, t1
			br get_modulo_twelve
			
			end_get_modulo_twelve:
				ret
	; END:find_neighbours


	
	; BEGIN:update_gsa
    update_gsa:

		ldw     t0, PAUSE(zero)
        beq     t0, zero, end_update_gsa

        addi    s0, zero, 8

        addi    sp, sp, -4
        stw     ra, 0(sp)

        addi    a1, zero, -1

        update_gsa_over_line:
        	addi    s0, s0, -1

        	add     s1, zero, zero

        	addi    s2, zero, 12

        update_gsa_over_element:
        	addi    s2, s2, -1

        	add     a1, s0, zero
        	add     a0, s2, zero
        	call    find_neighbours

       		add     a0, v0, zero
        	add     a1, v1, zero 
        	call    cell_fate

        	sll     v0, v0, s2
        	or      s1, s1, v0

        	bne     s2, zero, update_gsa_over_element
        	add     a0, s1, zero
        	add     a1, s0, zero

        	ldw     t0, GSA_ID(zero) 
        	xori     t0, t0, 1
        	stw     t0, GSA_ID(zero)

        	call    set_gsa

        	ldw     t0, GSA_ID(zero) 
        	xori     t0, t0, 1
        	stw     t0, GSA_ID(zero)

        	bne     s0, zero, update_gsa_over_line

        	ldw     t0, GSA_ID(zero) 
        	xori    t0, t0, 1
        	stw     t0, GSA_ID(zero)

        	ldw     ra, 0(sp)
        	addi    sp, sp, 4

        end_update_gsa:
        	ret
    ; END:update_gsa

	; BEGIN:mask
	mask:
		;your implementation code
		
		ldw t0, SEED(zero)
		slli t0, t0, 2
		ldw s0, MASKS(t0)

        addi s1, zero, -1

		mask_loop:
        	addi s1, s1, 1
        	add a0, s1, zero

			addi sp, sp, -4
			stw ra, 0(sp)
        	call get_gsa
			ldw ra, 0(sp)
			addi sp, sp, 4

        	add t0, v0, zero

        	slli t1, s1, 2
        	add t1, t1, s0
        	ldw t1, 0(t1)
        
        	and a0, t1, t0
       	 	add a1, s1, zero

        	addi sp, sp, -4
			stw ra, 0(sp)
        	call set_gsa
			ldw ra, 0(sp)
			addi sp, sp, 4

			addi t0,zero, N_GSA_LINES
       		bne s1, t0, mask_loop
			br end_mask
		
		end_mask:
			ret
	; END:mask

	; BEGIN:get_input
	get_input:
		;your implementation code
		ldw v0, 4 + BUTTONS(zero)
		ldw t0, 4 + BUTTONS(zero)
		srli t0, t0, 5
		slli t0, t0, 5
		stw t0,  4 + BUTTONS(zero)

		andi t1, v0, 1
		bne t1, zero, get_input_end_first
		andi t1, v0, 2
		bne t1, zero, get_input_end_second
		andi t1, v0, 4
		bne t1, zero, get_input_end_third
		andi t1, v0, 8
		bne t1, zero, get_input_end_fourth
		br get_input_end

		get_input_end_first:
			add v0, t0, zero
			ori v0, v0, 1
			br get_input_end

		get_input_end_second:
			add v0, t0, zero
			ori v0, v0, 2
			br get_input_end

		get_input_end_third:
			add v0, t0, zero
			ori v0, v0, 4
			br get_input_end

		get_input_end_fourth:
			add v0, t0, zero
			ori v0, v0, 8
			br get_input_end


		get_input_end:
			ret
	; END:get_input

; BEGIN:decrement_step
	decrement_step:
		;your implementation code
		ldw t0, CURR_STATE (zero)
		ldw t2, PAUSE(zero)
		ldw t3, CURR_STEP(zero)
		add s0, t3, zero

		addi t1, zero, RUN
		add v0, zero, zero

		beq t2, zero, decrement_get_modulo
		beq t0, t1, decrement_step_run

		br decrement_get_modulo

		decrement_step_run:

			cmpeq v0, t3, zero
			bne v0, zero, decrement_get_modulo
			addi t3, t3, -1
			stw t3, CURR_STEP(zero)
			add s0, t3, zero
			br decrement_get_modulo


		decrement_get_modulo:
		
			add s1, zero, zero
			add s2, zero, zero
			add s3, zero, zero
			add s4, zero, zero
	
			decrement_loop_mod1000:
				addi t1, s0, -4096
				blt t1, zero, decrement_loop_mod100
				addi s1, s1, 1
				add s0, t1, zero
				br decrement_loop_mod1000
		
			decrement_loop_mod100:
				addi t1, s0, -256
				blt t1, zero, decrement_loop_mod10
				addi s2, s2, 1
				add s0, t1, zero
				br decrement_loop_mod100

			decrement_loop_mod10:
				addi t1, s0, -16
				blt t1, zero, decrement_loop_mod1
				addi s3, s3, 1
				add s0, t1, zero
				br decrement_loop_mod10

			decrement_loop_mod1:
				addi t1, s0, -1
				blt t1, zero, decrement_display_mod
				addi s4, s4, 1
				add s0, t1, zero
				br decrement_loop_mod1
		
			decrement_display_mod:
				slli s1, s1, 2
				slli s2, s2, 2
				slli s3, s3, 2
				slli s4, s4, 2
				addi s1, s1, font_data
				addi s2, s2, font_data
				addi s3, s3, font_data
				addi s4, s4, font_data

				ldw s1, 0(s1)
				ldw s2, 0(s2)
				ldw s3, 0(s3)
				ldw s4, 0(s4)

				stw s1, SEVEN_SEGS(zero)
				stw s2, SEVEN_SEGS+4(zero)
				stw s3, SEVEN_SEGS+8(zero)
				stw s4, SEVEN_SEGS+12(zero)
			
				br decrement_step_end

		decrement_step_end:
			ret
		; END:decrement_step


font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
	.word mask4