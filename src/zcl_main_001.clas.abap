CLASS ZCL_MAIN_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_MAIN_001 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Declarar la clase customer manager
    DATA(lo_customer_manager) = NEW zcl_customer_manager_001( ).

    " Declarar tabla interna para almacenar resultados
    DATA: lt_customers TYPE TABLE OF ztcustomer_001.

    " Insertar 4 nuevos registros
    lo_customer_manager->add_customer( iv_id = 'C001' iv_name = 'Cliente A' iv_active = 'X' ).
    lo_customer_manager->add_customer( iv_id = 'C002' iv_name = 'Cliente B' iv_active = ' ' ).
    lo_customer_manager->add_customer( iv_id = 'C003' iv_name = 'Cliente C' iv_active = 'X' ).
    lo_customer_manager->add_customer( iv_id = 'C004' iv_name = 'Cliente D' iv_active = ' ' ).

    " Guardar en la base de datos
    lo_customer_manager->save_buffer( ).

    " Actualizar registros
    lo_customer_manager->update_customer( iv_id = 'C002' iv_name = 'Cliente B Modificado' iv_active = 'X' ).
    lo_customer_manager->update_customer( iv_id = 'C004' iv_name = 'Cliente D Modificado' iv_active = 'X' ).

    " Guardar en la base de datos
    lo_customer_manager->save_buffer( ).

    " Eliminar un registro
    lo_customer_manager->delete_customer( iv_id = 'C003' ).

    " Guardar en la base de datos
    lo_customer_manager->save_buffer( ).

    " Consultar la tabla y mostrar los resultados
    SELECT * FROM ztcustomer_001 INTO TABLE @lt_customers.

    LOOP AT lt_customers INTO DATA(ls_customer).
      out->write( |ID: { ls_customer-customer_id } Nombre: { ls_customer-customer_name } Activo: { ls_customer-customer_activo }| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
