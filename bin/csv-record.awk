# print out each row as
# key: value
function buildRec(fpat, fldNr, fldStr, done) {
  CurrRec = CurrRec $0;

  if (gsub(/"/, "&", CurrRec) % 2) {
    CurrRec = CurrRec RS;
    done = 0;
  } else {
    CurrRec = CurrRec (CurrRec ~ ("[" FS "]$") ? "\"\"" : "");
    $0 = "";
    fpat = "([^" FS "]*)|(\"([^\"]|\"\")+\")";

    while ((CurrRec != "") && match(CurrRec,fpat)) {
      fldStr = substr(CurrRec, RSTART, RLENGTH);
      # if (gsub(/^"|"$/, "", fldStr) ) {
      # }
      gsub(/""/, "\"", fldStr);
      gsub(/'/, "''", fldStr);
      $(++fldNr) = fldStr;
      CurrRec = substr(CurrRec, RSTART + RLENGTH + 1);
    }
    CurrRec = "";
    done = 1;
  }
  return done;
}

BEGIN {
  FS = OFS = FS ? FS : ",";

  FPAT = "[^" FS "]*|(\"([^\"]|\"\")*\")";
  OUT_FS = ",";
}

# !buildRec() { next; }

FNR == 1 {
  columns = NF;

  for (i = 1; i <= columns; ++i) {
    gsub(/[\r\n]+/, "", $i);
    names[i] = $i;
  }
}

FNR != 1 {
  printf("{\n");
  for (colnum in names) {
    printf("  %s: '%s'\n", names[colnum], $colnum);
  }
  printf("}\n");
  leader = FNR == 2 ? "  " : ",\n  ";
}
