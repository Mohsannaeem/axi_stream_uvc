// =============================================================================
// uvm_tracker — schema-driven, verbosity-independent tracker base class
// (uvc_generator SKILL §2 "Protocol-Aware Tracker Mechanism")
//
// Writes BOTH <dir>/<comp_name>_tracker.log (aligned columns) and
// <dir>/<comp_name>_tracker.csv (machine-readable). Output directory comes from
// +TRACKER_DIR via uvm_cmdline_processor — NOT $value$plusargs.
//
// The tracker is orthogonal to UVM verbosity: write_row() and the file
// lifecycle are NEVER wrapped in a verbosity guard, so a default UVM_MEDIUM
// run still produces a complete beat-level trace without log bloat.
// =============================================================================
`ifndef AXI_STREAM_MASTER_VIP_TRACKER_SV
`define AXI_STREAM_MASTER_VIP_TRACKER_SV

class uvm_tracker extends uvm_object;
  `uvm_object_utils(uvm_tracker)

  typedef struct {
    string name;
    int    width;
    string fmt;
  } col_t;

  protected col_t  cols[$];
  protected int    fd_txt      = 0;
  protected int    fd_csv      = 0;
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

  // Right-align `s` into `w` chars. Done by hand rather than with "%*s": the
  // '*' dynamic-width flag is not portable across SV simulators.
  protected function string pad(string s, int w);
    string r = s;
    while (r.len() < w) r = {" ", r};
    return r;
  endfunction

  // Open both files and write headers. Directory resolved from +TRACKER_DIR.
  function void open(string comp_name);
    string dir = ".";
    string log_path;
    string csv_path;
    uvm_cmdline_processor cmd = uvm_cmdline_processor::get_inst();
    void'(cmd.get_arg_value("+TRACKER_DIR=", dir));

    if (dir == "") dir = ".";
    file_prefix = comp_name;
    log_path    = $sformatf("%s/%s_tracker.log", dir, file_prefix);
    csv_path    = $sformatf("%s/%s_tracker.csv", dir, file_prefix);

    fd_txt = $fopen(log_path, "w");
    fd_csv = $fopen(csv_path, "w");

    if (fd_txt == 0 || fd_csv == 0) begin
      `uvm_error("TRACKER_OPEN",
                 $sformatf("Failed to open tracker files in directory %s", dir))
      return;
    end

    write_headers();
  endfunction

  protected function void write_headers();
    string txt_line = "";
    string sep_line = "";
    string csv_line = "";

    foreach (cols[i]) begin
      string cell_s = pad(cols[i].name, cols[i].width);
      string sep  = "";
      for (int j = 0; j < cols[i].width; j++) sep = {sep, "-"};

      if (i == 0) begin
        txt_line = cell_s;
        sep_line = sep;
        csv_line = cols[i].name;
      end
      else begin
        txt_line = {txt_line, " | ", cell_s};
        sep_line = {sep_line, "-+-", sep};
        csv_line = {csv_line, ",", cols[i].name};
      end
    end

    $fwrite(fd_txt, "%s\n", txt_line);
    $fwrite(fd_txt, "%s\n", sep_line);
    $fwrite(fd_csv, "%s\n", csv_line);
  endfunction

  // Write one row. Re-prints the header every 40 rows so a long trace stays
  // readable when scrolled.
  function void write_row(string vals[$]);
    string txt_line = "";
    string csv_line = "";

    if (fd_txt == 0 || fd_csv == 0) return;

    if (vals.size() != cols.size()) begin
      `uvm_warning("TRACKER_ROW_MISMATCH", "Row column size does not match schema size")
      return;
    end

    foreach (cols[i]) begin
      string cell_s = pad(vals[i], cols[i].width);
      if (i == 0) begin
        txt_line = cell_s;
        csv_line = vals[i];
      end
      else begin
        txt_line = {txt_line, " | ", cell_s};
        csv_line = {csv_line, ",", vals[i]};
      end
    end

    $fwrite(fd_txt, "%s\n", txt_line);
    $fwrite(fd_csv, "%s\n", csv_line);
    $fflush(fd_txt);
    $fflush(fd_csv);

    rows++;
    if (rows >= 40) begin
      rows = 0;
      write_headers();
    end
  endfunction

  function void close();
    if (fd_txt != 0) $fclose(fd_txt);
    if (fd_csv != 0) $fclose(fd_csv);
    fd_txt = 0;
    fd_csv = 0;
  endfunction

endclass

// ── Dynamic column sizing (SKILL: "Dynamic Column Sizing") ───────────────────
// hex_width  = (MACRO_WIDTH_VAL + 3) / 4
// column     = max(10, hex_width + 2)
// Widths reflow automatically when the defines.sv macros change.
`define TRK_HEXW(W)  (((W) + 3) / 4)
`define TRK_COLW(W)  ((`TRK_HEXW(W) + 2) > 10 ? (`TRK_HEXW(W) + 2) : 10)

`endif
