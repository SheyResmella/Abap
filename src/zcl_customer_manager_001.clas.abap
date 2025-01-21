CLASS ZCL_CUSTOMER_MANAGER_001 DEFINITION PUBLIC.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_customer_buffer,
             customer_id TYPE ztcustomer_001-customer_id,
             customer_name TYPE ztcustomer_001-customer_name,
             customer_activo TYPE ztcustomer_001-customer_activo,
             flag TYPE c LENGTH 1,  " Flag to identify the operation (C - Create, U - Update, D - Delete)
           END OF ty_customer_buffer.

    TYPES tt_customer_buffer TYPE SORTED TABLE OF ty_customer_buffer WITH UNIQUE KEY customer_id.

    CLASS-DATA mt_customer_buffer TYPE tt_customer_buffer.

    METHODS:
      add_customer IMPORTING iv_id TYPE ztcustomer_001-customer_id
                            iv_name TYPE ztcustomer_001-customer_name
                            iv_active TYPE ztcustomer_001-customer_activo,
      update_customer IMPORTING iv_id TYPE ztcustomer_001-customer_id
                               iv_name TYPE ztcustomer_001-customer_name
                               iv_active TYPE ztcustomer_001-customer_activo,
      delete_customer IMPORTING iv_id TYPE ztcustomer_001-customer_id,
      save_buffer.  " To save buffer to DB
ENDCLASS.

CLASS ZCL_CUSTOMER_MANAGER_001 IMPLEMENTATION.

  METHOD add_customer.
    " Add customer to buffer
    DATA(ls_customer) = VALUE ty_customer_buffer( customer_id = iv_id
                                                  customer_name = iv_name
                                                  customer_activo = iv_active
                                                  flag = 'C' ).  " C for Create
    INSERT ls_customer INTO TABLE mt_customer_buffer.
  ENDMETHOD.

  METHOD update_customer.
    " Update customer in buffer
    READ TABLE mt_customer_buffer WITH KEY customer_id = iv_id ASSIGNING FIELD-SYMBOL(<ls_buffer>).
    IF sy-subrc = 0.
      <ls_buffer>-customer_name = iv_name.
      <ls_buffer>-customer_activo = iv_active.
      <ls_buffer>-flag = 'U'.  " U for Update
    ELSE.
      " If not found in buffer, retrieve from DB and update
      SELECT SINGLE * FROM ztcustomer_001 WHERE customer_id = @iv_id INTO @DATA(ls_db).
      IF sy-subrc = 0.
        INSERT VALUE #( customer_id = iv_id
                        customer_name = iv_name
                        customer_activo = iv_active
                        flag = 'U' ) INTO TABLE mt_customer_buffer.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD delete_customer.
    " Delete customer by marking as 'D' in buffer
    INSERT VALUE #( customer_id = iv_id flag = 'D' ) INTO TABLE mt_customer_buffer.
  ENDMETHOD.

  METHOD save_buffer.
    " Save buffer data to database for Create, Update and Delete operations
    DATA lt_create TYPE STANDARD TABLE OF ztcustomer_001.
    DATA lt_update TYPE STANDARD TABLE OF ztcustomer_001.
    DATA lt_delete TYPE STANDARD TABLE OF ztcustomer_001.

    " Process creates
    LOOP AT mt_customer_buffer INTO DATA(ls_buffer) WHERE ( flag = 'C' ).
      APPEND VALUE #( customer_id = ls_buffer-customer_id
                      customer_name = ls_buffer-customer_name
                      customer_activo = ls_buffer-customer_activo ) TO lt_create.
    ENDLOOP.

    IF lt_create IS NOT INITIAL.
      INSERT ztcustomer_001 FROM TABLE @lt_create.
    ENDIF.

    " Process updates
    LOOP AT mt_customer_buffer INTO ls_buffer WHERE ( flag = 'U' ).
      MODIFY ztcustomer_001 FROM @ls_buffer.
    ENDLOOP.

    " Process deletes
    LOOP AT mt_customer_buffer INTO ls_buffer WHERE ( flag = 'D' ).
      DELETE FROM ztcustomer_001 WHERE customer_id = @ls_buffer-customer_id.
    ENDLOOP.

    " Clear buffer after saving to DB
    CLEAR mt_customer_buffer.
  ENDMETHOD.

ENDCLASS.

