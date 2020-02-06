(* DWARF 5 constants *)

let dw_CHILDREN_no = 0x00
let dw_CHILDREN_yes = 0x01

let dw_TAG_array_type = 0x01
let dw_TAG_class_type = 0x02
let dw_TAG_entry_point = 0x03
let dw_TAG_enumeration_type = 0x04
let dw_TAG_formal_parameter = 0x05
(* let Reserved = 0x06 *)
(* let Reserved = 0x07 *)
let dw_TAG_imported_declaration = 0x08
(* let Reserved = 0x09 *)
let dw_TAG_label = 0x0a
let dw_TAG_lexical_block = 0x0b
(* let Reserved = 0x0c *)
let dw_TAG_member = 0x0d
(* let Reserved = 0x0e *)
let dw_TAG_pointer_type = 0x0f
let dw_TAG_reference_type = 0x10
let dw_TAG_compile_unit = 0x11
let dw_TAG_string_type = 0x12
let dw_TAG_structure_type = 0x13
(* let Reserved = 0x14 *)
let dw_TAG_subroutine_type = 0x15
let dw_TAG_typedef = 0x16
let dw_TAG_union_type = 0x17
let dw_TAG_unspecified_parameters = 0x18
let dw_TAG_variant = 0x19
let dw_TAG_common_block = 0x1a
let dw_TAG_common_inclusion = 0x1b
let dw_TAG_inheritance = 0x1c
let dw_TAG_inlined_subroutine = 0x1d
let dw_TAG_module = 0x1e
let dw_TAG_ptr_to_member_type = 0x1f
let dw_TAG_set_type = 0x20
let dw_TAG_subrange_type = 0x21
let dw_TAG_with_stmt = 0x22
let dw_TAG_access_declaration = 0x23
let dw_TAG_base_type = 0x24
let dw_TAG_catch_block = 0x25
let dw_TAG_const_type = 0x26
let dw_TAG_constant = 0x27
let dw_TAG_enumerator = 0x28
let dw_TAG_file_type = 0x29
let dw_TAG_friend = 0x2a
let dw_TAG_namelist = 0x2b
let dw_TAG_namelist_item = 0x2c
let dw_TAG_packed_type = 0x2d
let dw_TAG_subprogram = 0x2e
let dw_TAG_template_type_parameter = 0x2f
let dw_TAG_template_value_parameter = 0x30
let dw_TAG_thrown_type = 0x31
let dw_TAG_try_block = 0x32
let dw_TAG_variant_part = 0x33
let dw_TAG_variable = 0x34
let dw_TAG_volatile_type = 0x35
let dw_TAG_dwarf_procedure = 0x36
let dw_TAG_restrict_type = 0x37
let dw_TAG_interface_type = 0x38
let dw_TAG_namespace = 0x39
let dw_TAG_imported_module = 0x3a
let dw_TAG_unspecified_type = 0x3b
let dw_TAG_partial_unit = 0x3c
let dw_TAG_imported_unit = 0x3d
(* let Reserved = 0x3e *)
let dw_TAG_condition = 0x3f
let dw_TAG_shared_type = 0x40
let dw_TAG_type_unit = 0x41
let dw_TAG_rvalue_reference_type = 0x42
let dw_TAG_template_alias = 0x43
let dw_TAG_coarray_type = 0x44
let dw_TAG_generic_subrange = 0x45
let dw_TAG_dynamic_type = 0x46
let dw_TAG_atomic_type = 0x47
let dw_TAG_call_site = 0x48
let dw_TAG_call_site_parameter = 0x49
let dw_TAG_skeleton_unit = 0x4a
let dw_TAG_immutable_type = 0x4b
let dw_TAG_lo_user = 0x4080
let dw_TAG_hi_user = 0xffff


let dw_AT_sibling = 0x01
let dw_AT_location = 0x02
let dw_AT_name = 0x03
(* let Reserved = 0x04 *)
(* let Reserved = 0x05 *)
(* let Reserved = 0x06 *)
(* let Reserved = 0x07 *)
(* let Reserved = 0x08 *)
let dw_AT_ordering = 0x09
(* let Reserved = 0x0a *)
let dw_AT_byte_size = 0x0b
(* let Reserved = 0x0c *)
let dw_AT_bit_size = 0x0d
(* let Reserved = 0x0e *)
(* let Reserved = 0x0f *)
let dw_AT_stmt_list = 0x10
let dw_AT_low_pc = 0x11
let dw_AT_high_pc = 0x12
let dw_AT_language = 0x13
(* let Reserved = 0x14 *)
let dw_AT_discr = 0x15
let dw_AT_discr_value = 0x16
let dw_AT_visibility = 0x17
let dw_AT_import = 0x18
let dw_AT_string_length = 0x19
let dw_AT_common_reference = 0x1a
let dw_AT_comp_dir = 0x1b
let dw_AT_const_value = 0x1c
let dw_AT_containing_type = 0x1d
let dw_AT_default_value = 0x1e
(* let Reserved = 0x1f *)
let dw_AT_inline = 0x20
let dw_AT_is_optional = 0x21
let dw_AT_lower_bound = 0x22
(* let Reserved = 0x23 *)
(* let Reserved = 0x24 *)
let dw_AT_producer = 0x25
(* let Reserved = 0x26 *)
let dw_AT_prototyped = 0x27
(* let Reserved = 0x28 *)
(* let Reserved = 0x29 *)
let dw_AT_return_addr = 0x2a
(* let Reserved = 0x2b *)
let dw_AT_start_scope = 0x2c
(* let Reserved = 0x2d *)
let dw_AT_bit_stride = 0x2e
let dw_AT_upper_bound = 0x2f
(* let Reserved = 0x30 *)
let dw_AT_abstract_origin = 0x31
let dw_AT_accessibility = 0x32
let dw_AT_address_class = 0x33
let dw_AT_artificial = 0x34
let dw_AT_base_types = 0x35
let dw_AT_calling_convention = 0x36
let dw_AT_count = 0x37
let dw_AT_data_member_location = 0x38
let dw_AT_decl_column = 0x39
let dw_AT_decl_file = 0x3a
let dw_AT_decl_line = 0x3b
let dw_AT_declaration = 0x3c
let dw_AT_discr_list = 0x3d
let dw_AT_encoding = 0x3e
let dw_AT_external = 0x3f
let dw_AT_frame_base = 0x40
let dw_AT_friend = 0x41
let dw_AT_identifier_case = 0x42
(* let Reserved = 0x43 *)
let dw_AT_namelist_item = 0x44
let dw_AT_priority = 0x45
let dw_AT_segment = 0x46
let dw_AT_specification = 0x47
let dw_AT_static_link = 0x48
let dw_AT_type = 0x49
let dw_AT_use_location = 0x4a
let dw_AT_variable_parameter = 0x4b
let dw_AT_virtuality = 0x4c
let dw_AT_vtable_elem_location = 0x4d
let dw_AT_allocated = 0x4e
let dw_AT_associated = 0x4f
let dw_AT_data_location = 0x50
let dw_AT_byte_stride = 0x51
let dw_AT_entry_pc = 0x52
let dw_AT_use_UTF8 = 0x53
let dw_AT_extension = 0x54
let dw_AT_ranges = 0x55
let dw_AT_trampoline = 0x56
let dw_AT_call_column = 0x57
let dw_AT_call_file = 0x58
let dw_AT_call_line = 0x59
let dw_AT_description = 0x5a
let dw_AT_binary_scale = 0x5b
let dw_AT_decimal_scale = 0x5c
let dw_AT_small = 0x5d
let dw_AT_decimal_sign = 0x5e
let dw_AT_digit_count = 0x5f
let dw_AT_picture_string = 0x60
let dw_AT_mutable = 0x61
let dw_AT_threads_scaled = 0x62
let dw_AT_explicit = 0x63
let dw_AT_object_pointer = 0x64
let dw_AT_endianity = 0x65
let dw_AT_elemental = 0x66
let dw_AT_pure = 0x67
let dw_AT_recursive = 0x68
let dw_AT_signature = 0x69
let dw_AT_main_subprogram = 0x6a
let dw_AT_data_bit_offset = 0x6b
let dw_AT_const_expr = 0x6c
let dw_AT_enum_class = 0x6d
let dw_AT_linkage_name = 0x6e
let dw_AT_string_length_bit_size = 0x6f
let dw_AT_string_length_byte_size = 0x70
let dw_AT_rank = 0x71
let dw_AT_str_offsets_base = 0x72
let dw_AT_addr_base = 0x73
let dw_AT_rnglists_base = 0x74
(* let Reserved = 0x75 *)
let dw_AT_dwo_name = 0x76
let dw_AT_reference = 0x77
let dw_AT_rvalue_reference = 0x78
let dw_AT_macros = 0x79
let dw_AT_call_all_calls = 0x7a
let dw_AT_call_all_source_calls = 0x7b
let dw_AT_call_all_tail_calls = 0x7c
let dw_AT_call_return_pc = 0x7d
let dw_AT_call_value = 0x7e
let dw_AT_call_origin = 0x7f
let dw_AT_call_parameter = 0x80
let dw_AT_call_pc = 0x81
let dw_AT_call_tail_call = 0x82
let dw_AT_call_target = 0x83
let dw_AT_call_target_clobbered = 0x84
let dw_AT_call_data_location = 0x85
let dw_AT_call_data_value = 0x86
let dw_AT_noreturn = 0x87
let dw_AT_alignment = 0x88
let dw_AT_export_symbols = 0x89
let dw_AT_deleted = 0x8a
let dw_AT_defaulted = 0x8b
let dw_AT_loclists_base = 0x8c
let dw_AT_lo_user = 0x2000
let dw_AT_hi_user = 0x3fff

let dw_FORM_addr = 0x01
(* Reserved = 0x02 *)
let dw_FORM_block2 = 0x03
let dw_FORM_block4 = 0x04
let dw_FORM_data2 = 0x05
let dw_FORM_data4 = 0x06
let dw_FORM_data8 = 0x07
let dw_FORM_string = 0x08
let dw_FORM_block = 0x09
let dw_FORM_block1 = 0x0a
let dw_FORM_data1 = 0x0b
let dw_FORM_flag = 0x0c
let dw_FORM_sdata = 0x0d
let dw_FORM_strp = 0x0e
let dw_FORM_udata = 0x0f
let dw_FORM_ref_addr = 0x10
let dw_FORM_ref1 = 0x11
let dw_FORM_ref2 = 0x12
let dw_FORM_ref4 = 0x13
let dw_FORM_ref8 = 0x14
let dw_FORM_ref_udata = 0x15
let dw_FORM_indirect = 0x16
let dw_FORM_sec_offset = 0x17
let dw_FORM_exprloc = 0x18
let dw_FORM_flag_present = 0x19
let dw_FORM_strx = 0x1a
let dw_FORM_addrx = 0x1b
let dw_FORM_ref_sup4 = 0x1c
let dw_FORM_strp_sup = 0x1d
let dw_FORM_data16 = 0x1e
let dw_FORM_line_strp = 0x1f
let dw_FORM_ref_sig8 = 0x20
let dw_FORM_implicit_const = 0x21
let dw_FORM_loclistx = 0x22
let dw_FORM_rnglistx = 0x23
let dw_FORM_ref_sup8 = 0x24
let dw_FORM_strx1 = 0x25
let dw_FORM_strx2 = 0x26
let dw_FORM_strx3 = 0x27
let dw_FORM_strx4 = 0x28
let dw_FORM_addrx1 = 0x29
let dw_FORM_addrx2 = 0x2a
let dw_FORM_addrx3 = 0x2b
let dw_FORM_addrx4 = 0x2c

(* FIXME: we cheat for now *)
let dw_LANG_Swift = 0x001e


let dw_UT_compile = 0x01
let dw_UT_type = 0x02
let dw_UT_partial = 0x03
let dw_UT_skeleton = 0x04
let dw_UT_split_compile = 0x05
let dw_UT_split_type = 0x06
let dw_UT_lo_user = 0x80
let dw_UT_hi_user = 0xff



(* Line number header entry format name *)
let dw_LNCT_path = 0x1
let dw_LNCT_directory_index = 0x2
let dw_LNCT_timestamp = 0x3
let dw_LNCT_size = 0x4
let dw_LNCT_MD5 = 0x5
let dw_LNCT_lo_user = 0x2000
let dw_LNCT_hi_user = 0x3fff

(* Line number standard opcode encodings *)
let dw_LNS_copy = 0x01
let dw_LNS_advance_pc = 0x02
let dw_LNS_advance_line = 0x03
let dw_LNS_set_file = 0x04
let dw_LNS_set_column = 0x05
let dw_LNS_negate_stmt = 0x06
let dw_LNS_set_basic_block = 0x07
let dw_LNS_const_add_pc = 0x08
let dw_LNS_fixed_advance_pc = 0x09
let dw_LNS_set_prologue_end = 0x0a
let dw_LNS_set_epilogue_begin = 0x0b
let dw_LNS_set_isa = 0x0c

(* Line number extended opcode encodings *)
let dw_LNE_end_sequence = 0x01
let dw_LNE_set_address = 0x02
(* let Reserved 0x03 *)
let dw_LNE_set_discriminator = 0x04
let dw_LNE_lo_user = 0x80
let dw_LNE_hi_user = 0xff

module Machine =
struct

(* Assumptions:
- op_index = 0 (const)
- maximum_operations_per_instruction = 1 (non-VLIW)
- minimum_instruction_length = 1 (bytecode)
 *)

let default_is_stmt = true
let line_base = 0
let line_range = 7
let opcode_base = dw_LNS_set_isa

type state = int * (int * int * int) * int * (bool * bool * bool * bool)
let default_loc = (0, 0, 0)

let interpret (out : state -> unit) : int list -> state -> state =
  function
  | c :: t when dw_LNS_copy = c ->
    fun ((op, loc, disc, (s, _, _, _)) as st) ->
    out st; (op, loc, 0, (s, false, false, false))
  | c :: offs :: t when dw_LNS_advance_pc = c ->
    fun (op, loc, disc, flags) -> (op + offs, loc, disc, flags)
  | c :: offs :: t when dw_LNS_advance_line = c ->
    fun (op, (line, col, file), disc, flags) -> (op, (line + offs, col, file), disc, flags)
  | c :: file :: t when dw_LNS_set_file = c ->
    fun (op, (line, col, _), disc, flags) -> (op, (line, col, file), disc, flags)
  | c :: col :: t when dw_LNS_set_column = c ->
    fun (op, (line, _, file), disc, flags) -> (op, (line, col, file), disc, flags)
  | c :: t when dw_LNS_negate_stmt = c ->
    fun (op, loc, disc, (s, bb, pe, eb)) -> (op, loc, disc, (not s, bb, pe, eb))
  | c :: t when dw_LNS_set_basic_block = c ->
    fun (op, loc, disc, (s, _, pe, eb)) -> (op, loc, disc, (s, true, pe, eb))
(* dw_LNS_const_add_pc, dw_LNS_fixed_advance_pc NOT YET *)
  | c :: t when dw_LNS_set_prologue_end = c ->
    fun (op, loc, disc, (s, bb, _, eb)) -> (op, loc, disc, (s, bb, true, eb))
  | c :: t when dw_LNS_set_epilogue_begin = c ->
    fun (op, loc, disc, (s, bb, pe, _)) -> (op, loc, disc, (s, bb, pe, true))

  | [c] when dw_LNE_end_sequence = c -> (* FIXME: model end_sequence *)
    fun ((op, _, disc, _) as st) ->
    out st; (0, default_loc, 0, (default_is_stmt, false, false, false))

  | c :: op :: t when dw_LNE_set_address = c ->
    fun (_, loc, disc, flags) -> (op, loc, disc, flags)
  | c :: disc :: t when dw_LNE_set_discriminator = c ->
    fun (op, loc, _, flags) -> (op, loc, disc, flags)

  | prg -> failwith "invalid program"




let rec infer from toward = match from, toward with
  | (f, _, _, _), (t, _, _, _) when t < f -> failwith "can't go backwards"
  | (0, loc, disc, flags), (t, loc', disc', flags') when t > 0 ->
    dw_LNS_const_add_pc :: t :: infer (t, loc, disc, flags) (t, loc', disc', flags')
  | (f, loc, disc, flags), (t, loc', disc', flags') when t > f ->
    dw_LNS_const_add_pc :: t - f :: infer (t, loc, disc, flags) (t, loc', disc', flags')
  | (_, (file, line, col), disc, flags), (t, (file', line', col'), disc', flags') when file <> file' ->
    dw_LNS_set_file :: file' :: infer (t, (file', line, col), disc, flags) (t, (file', line', col'), disc', flags')
  | (_, (_, line, col), disc, flags), (t, (file, line', col'), disc', flags') when line <> line' ->
    dw_LNS_advance_line :: line' - line :: infer (t, (file, line', col), disc, flags) (t, (file, line', col'), disc', flags')
  | (_, (_, _, col), disc, flags), (t, (file, line, col'), disc', flags') when col <> col' ->
    dw_LNS_set_column :: col' :: infer (t, (file, line, col'), disc', flags') (t, (file, line, col'), disc', flags')
  | (_, _, disc, flags), (t, loc, disc', flags') when disc <> disc' -> failwith "cannot do disc yet"
  | (_, _, _, (s, bb, ep, eb)), (t, loc, disc, (s', bb', ep', eb')) when s <> s' ->
    dw_LNS_negate_stmt :: infer (t, loc, disc, (s', bb, ep, eb)) (t, loc, disc, (s', bb', ep', eb'))
  | state, state' when state = state' -> []
  | _ -> failwith "not covered"

end
