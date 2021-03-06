CLASS zcl_abapgit_object_iext DEFINITION PUBLIC INHERITING FROM zcl_abapgit_objects_super FINAL.

  PUBLIC SECTION.
    INTERFACES zif_abapgit_object.
    ALIASES mo_files FOR zif_abapgit_object~mo_files.
    METHODS:
      constructor
        IMPORTING
          is_item     TYPE zif_abapgit_definitions=>ty_item
          iv_language TYPE spras.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_extention,
        attributes TYPE edi_iapi01,
        t_syntax   TYPE STANDARD TABLE OF edi_iapi03 WITH NON-UNIQUE DEFAULT KEY,
      END OF ty_extention.

    DATA:
      mv_extension TYPE edi_cimtyp.

ENDCLASS.



CLASS zcl_abapgit_object_iext IMPLEMENTATION.


  METHOD constructor.

    super->constructor( is_item = is_item
                        iv_language = iv_language ).

    mv_extension = ms_item-obj_name.

  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.

    DATA: ls_attributes TYPE edi_iapi01.

    CALL FUNCTION 'EXTTYPE_READ'
      EXPORTING
        pi_cimtyp     = mv_extension
      IMPORTING
        pe_attributes = ls_attributes
      EXCEPTIONS
        OTHERS        = 1.

    rv_user = ls_attributes-plast.

  ENDMETHOD.


  METHOD zif_abapgit_object~compare_to_remote_version.
    CREATE OBJECT ro_comparison_result TYPE zcl_abapgit_comparison_null.
  ENDMETHOD.


  METHOD zif_abapgit_object~delete.

    CALL FUNCTION 'EXTTYPE_DELETE'
      EXPORTING
        pi_cimtyp = mv_extension
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise_t100( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

    DATA: ls_extension  TYPE ty_extention,
          ls_attributes TYPE edi_iapi05.

    io_xml->read(
      EXPORTING
        iv_name = 'IEXT'
      CHANGING
        cg_data = ls_extension ).

    MOVE-CORRESPONDING ls_extension-attributes TO ls_attributes.
    ls_attributes-presp = cl_abap_syst=>get_user_name( ).
    ls_attributes-pwork = ls_attributes-presp.

    CALL FUNCTION 'EXTTYPE_CREATE'
      EXPORTING
        pi_cimtyp     = mv_extension
        pi_devclass   = iv_package
        pi_attributes = ls_attributes
      TABLES
        pt_syntax     = ls_extension-t_syntax
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise_t100( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~exists.

    CALL FUNCTION 'EXTTYPE_READ'
      EXPORTING
        pi_cimtyp = mv_extension
      EXCEPTIONS
        OTHERS    = 1.

    rv_bool = boolc( sy-subrc = 0 ).

  ENDMETHOD.


  METHOD zif_abapgit_object~get_metadata.
    rs_metadata = get_metadata( ).
  ENDMETHOD.


  METHOD zif_abapgit_object~has_changed_since.
    rv_changed = abap_true.
  ENDMETHOD.


  METHOD zif_abapgit_object~jump.

    DATA: lt_bdcdata TYPE TABLE OF bdcdata.

    FIELD-SYMBOLS: <ls_bdcdata> LIKE LINE OF lt_bdcdata.

    APPEND INITIAL LINE TO lt_bdcdata ASSIGNING <ls_bdcdata>.
    <ls_bdcdata>-program  = 'SAPMSED5'.
    <ls_bdcdata>-dynpro   = '0010'.
    <ls_bdcdata>-dynbegin = abap_true.

    APPEND INITIAL LINE TO lt_bdcdata ASSIGNING <ls_bdcdata>.
    <ls_bdcdata>-fnam = 'SED5STRUC-OBJECT'.
    <ls_bdcdata>-fval = ms_item-obj_name.

    APPEND INITIAL LINE TO lt_bdcdata ASSIGNING <ls_bdcdata>.
    <ls_bdcdata>-fnam = 'SED5STRUC-SELECT_EXT'.
    <ls_bdcdata>-fval = abap_true.

    APPEND INITIAL LINE TO lt_bdcdata ASSIGNING <ls_bdcdata>.
    <ls_bdcdata>-fnam = 'BDC_OKCODE'.
    <ls_bdcdata>-fval = '=DISP'.

    CALL FUNCTION 'ABAP4_CALL_TRANSACTION'
      STARTING NEW TASK 'GIT'
      EXPORTING
        tcode     = 'WE30'
        mode_val  = 'E'
      TABLES
        using_tab = lt_bdcdata
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise_t100( ).
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~serialize.

    DATA: ls_extension TYPE ty_extention.

    CALL FUNCTION 'EXTTYPE_READ'
      EXPORTING
        pi_cimtyp     = mv_extension
      IMPORTING
        pe_attributes = ls_extension-attributes
      TABLES
        pt_syntax     = ls_extension-t_syntax
      EXCEPTIONS
        OTHERS        = 1.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise_t100( ).
    ENDIF.

    CLEAR: ls_extension-attributes-devc,
           ls_extension-attributes-plast,
           ls_extension-attributes-credate,
           ls_extension-attributes-cretime,
           ls_extension-attributes-ldate,
           ls_extension-attributes-ltime,
           ls_extension-attributes-pwork,
           ls_extension-attributes-presp.

    io_xml->add( iv_name = 'IEXT'
                 ig_data = ls_extension ).

  ENDMETHOD.

  METHOD zif_abapgit_object~is_locked.

    rv_is_locked = abap_false.

  ENDMETHOD.

ENDCLASS.
