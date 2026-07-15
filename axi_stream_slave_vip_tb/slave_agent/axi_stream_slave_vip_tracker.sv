// =============================================================================
// uvm_tracker — schema-driven, verbosity-independent tracker base class
// (uvc_generator SKILL §2 "Protocol-Aware Tracker Mechanism").
//
// Log-only per the current skill class (fd_txt only). Directory is passed IN by
// the caller (agent_config resolves +TRACKER_DIR via get_cli_args), so the
// tracker class itself does not read plusargs. One instance in the driver, one
// in the monitor. Located under slave_agent/ per SKILL §291/§337.
//
// Two deviations from the skill's reference code, both required to compile on
// QuestaSim 2021.1:
//   - `cell` is a reserved SystemVerilog keyword (config/library) -> `cell_s`.
//   - "%*s" dynamic-width is not portable SV -> explicit pad() helper.
// =============================================================================
`ifndef AXI_STREAM_SLAVE_VIP_TRACKER_SV
`define AXI_STREAM_SLAVE_VIP_TRACKER_SV

class uvm_tracker extends uvm_object;
  `uvm_object_utils(uvm_tracker)

  typedef struct {
    string name;
    int    width;
    string fmt;
  } col_t;

  protected col_t  cols[$];
  protected int    fd_txt      = 0;
  protected int    rows        = 0;
  protected string file_prefix = "";

  function new(string name = "uvm_tracker");
    super.new(name);
  endfunction

  function void add_column(string name, int width, string fmt);
    col_t col;
    col.name  = name;
    col.width = width;
    col.fmt   = fmt;
    cols.push_back(col);
  endfunction

  protected function string pad(string s, int w);
    string r = s;
    while (r.len() < w) r = {" ", r};
    return r;
  endfunction

  // Open the log and write headers. Directory is supplied by the caller.
  function void open(string comp_name, string dir = ".");
    string log_path;
    file_prefix = comp_name;
    log_path    = $sformatf("%s/%s_tracker.log", dir, file_prefix);
    fd_txt      = $fopen(log_path, "w");
    if (fd_txt == 0) begin
      `uvm_error("TRACKER_OPEN",
                 $sformatf("Failed to open tracker file in directory %s", dir))
      return;
    end
    write_headers();
  endfunction

  protected function void write_headers();
    string txt_line = "";
    string sep_line = "";
    foreach (cols[i]) begin
      string cell_s = pad(cols[i].name, cols[i].width);
      string sep    = "";
      for (int j = 0; j < cols[i].width; j++) sep = {sep, "-"};
      if (i == 0) begin
        txt_line = cell_s;
        sep_line = sep;
      end
      else begin
        txt_line = {txt_line, " | ", cell_s};
        sep_line = {sep_line, "-+-", sep};
      end
    end
    $fwrite(fd_txt, "%s\n", txt_line);
    $fwrite(fd_txt, "%s\n", sep_line);
  endfunction

  function void write_row(string vals[$]);
    string txt_line = "";
    if (fd_txt == 0) return;
    if (vals.size() != cols.size()) begin
      `uvm_warning("TRACKER_ROW_MISMATCH", "Row column size does not match schema size")
      return;
    end
    foreach (cols[i]) begin
      string cell_s = pad(vals[i], cols[i].width);
      if (i == 0) txt_line = cell_s;
      else        txt_line = {txt_line, " | ", cell_s};
    end
    $fwrite(fd_txt, "%s\n", txt_line);
    $fflush(fd_txt);
    rows++;
    if (rows >= 40) begin
      rows = 0;
      write_headers();
    end
  endfunction

  function void close();
    if (fd_txt != 0) $fclose(fd_txt);
    fd_txt = 0;
  endfunction

endclass

// ── Dynamic column sizing (SKILL: "Dynamic Column Sizing") ───────────────────
// hex_width = (W + 3)/4 ; column = max(10, hex_width + 2). Reflows on macro change.
`define TRK_HEXW(W)  (((W) + 3) / 4)
`define TRK_COLW(W)  ((`TRK_HEXW(W) + 2) > 10 ? (`TRK_HEXW(W) + 2) : 10)

`endif
