sub ins_def { 
  my $subname = 'ins_def';
  { no warnings; &Csgrouper::says($subname, "@_"); }
  my $oldebflag = $Csgrouper::DEBFLAG; 
  # $Csgrouper::DEBFLAG = 1;
  my $pref = "i1";
  $CsgObj->instruments->{$pref.'_author'} = "csound";
  $CsgObj->instruments->{$pref.'_name'} = "Simple Sine";
  $CsgObj->instruments->{$pref.'_comment'} = "A basic instrument.";
  $CsgObj->instruments->{$pref.'_id'} = 1;
  $CsgObj->instruments->{$pref.'_type'} = "sine";
  $CsgObj->instruments->{$pref.'_path'} = "internal";
  $CsgObj->instruments->{$pref.'_content'} = 
  "\n idur = p3;\n".
  "iamp = p4;\n".
  "ifq1 = p5;\n".
  "ift1 = p6;\n".
  "irvn = p7;\n".
  "irvs = p8;\n".
  "a1  oscil ampdb(iamp), ifq1, ift1 ;\n".
  "garvbsig = garvbsig+(a1*irvs);\n".
  "outs a1,a1 ;\n".
	"endin ;\n";
  $CsgObj->instruments->{$pref.'_p3_fun'} = "dur";
  $CsgObj->instruments->{$pref.'_p3_def'} = "1";
  $CsgObj->instruments->{$pref.'_p4_fun'} = "amp";
  $CsgObj->instruments->{$pref.'_p4_def'} = "60";
  $CsgObj->instruments->{$pref.'_p5_fun'} = "fq1";
  $CsgObj->instruments->{$pref.'_p5_def'} = "440";
  $CsgObj->instruments->{$pref.'_p6_fun'} = "ft1";
  $CsgObj->instruments->{$pref.'_p6_def'} = "10";
  $CsgObj->instruments->{$pref.'_p7_fun'} = "rvn";
  $CsgObj->instruments->{$pref.'_p7_def'} = "1";
  $CsgObj->instruments->{$pref.'_p8_fun'} = "rvs";
  $CsgObj->instruments->{$pref.'_p8_def'} = "0.2";

  ## Now create or refresh the corresponding tab (-$pref = not XML storable).
  if (exists $CsgObj->instruments->{"I1"}) { $Orcbook->delete($pref) }
  $CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);

  $CsgObj->instruments->{"I1"} = &Csgrouper::Datem();

  ## File name, Title, Desc, Comments text flds
  $CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
  $CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
  $CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
  $CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( 
  	-textvariable=>\$CsgObj->instruments->{$pref.'_path'}
  	,-background=>$COLOR{input_bgcolor}
  	,-state=>'normal',  
  )->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
		,-top=>['%1',4]
		,-right=>['%40',0]
	);

  $CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Author: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
	-top=>['%1',4]
	,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Ins. name: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
  );

  ## ### Multi choice: $COLOR{'button_bgcolor'}
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'amp',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'amp'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'ampdb',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'ampdb'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cps',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cps'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cpspch',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cpspch'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'midi',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'midi'
		,-underline => 0
	);
	
  $CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
	-top=>['%1',4]
	,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
  );

  $CsgObj->instruments->{'-'.$pref.'_param_nbr'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Param. nbr: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>'1'
		,-width => 4
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'digit') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_param_nbr'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_type_text'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
  $CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		,-right=>['%99',0]
		## XXX WARNING wrap option produces an error when not in scrolled text.
  );
  $CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
  
  ## Default params table  with zeroes if no previous data in i576_p4 e.g.
  my $parnum = 2;
  $CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
		-rows => 3
		,-columns => ($parnum+1)
		,-relief=>'groove'
		,-scrollbars => 'se' 
		,-fixedrows => 1
		,-fixedcolumns => 1
		,-takefocus => 'on'
  );
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
  for (my $n = 1; $n <= $parnum; $n++) {
		my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
		my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
		my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
		$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
		$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
		$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
  }
  $CsgObj->instruments->{'-'.$pref.'_table'}->form(
		-left=>['%1',0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
		,-right=>['%99',0]
  );

  ## Delete button. 
  $CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Delete'
	  ,-state=>'disabled'
	  ,-command=>\sub { &ins_del($pref) }
  )->form(
		-right=>['%99',4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

  ## Save as button. 
  $CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Save As'
	  ,-state=>'normal'
	  ,-command=>\sub {ins_sas($pref)}
  )->form(
		-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

	## Save changes button. 
	$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
		-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-text=>'Update'
		,-state=>'normal'
		,-command=>\&ins_update
	)->form(
	  -right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
	);

	## New ins button. 
	$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
	  -text=>'New',
	  -menuitems => [
		  ['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
		  ['command' => 'New FX', -command => sub { &ins_new('fx') } ],
	  ]	
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
	)->form(
 	  -right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
 	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
 	);                 		

  ## Instrument text field (modifiable). 
  $CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
		'TextUndo'
		, -background=>$COLOR{input_bgcolor}
		, -foreground =>$COLOR{input_fgcolor}
		, -scrollbars => 'se' 
		, -wrap => 'word' 
		);
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
		-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
		, -left=>['%1',0], -right=>['%99',0]
		, -bottom=>['%98',0]
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents(
		"instr ".$CsgObj->instruments->{$pref.'_id'}.
		$CsgObj->instruments->{$pref.'_content'}
  );
  ## ### Now the same with instrument 576
  $pref = "i576";
  $CsgObj->instruments->{$pref.'_author'} = "csound";
  $CsgObj->instruments->{$pref.'_name'} = "Gobal Reverb";
  $CsgObj->instruments->{$pref.'_comment'} = "An instrument that is receiving input from a global variable should have a higher number than any instrument that are producing output for that variable.(R. Pinkston)";
  $CsgObj->instruments->{$pref.'_id'} = 576;
  $CsgObj->instruments->{$pref.'_type'} = "fx";
  $CsgObj->instruments->{$pref.'_amp_type'} = "";
  $CsgObj->instruments->{$pref.'_freq_type'} = "";
  $CsgObj->instruments->{$pref.'_path'} = "internal";
  $CsgObj->instruments->{$pref.'_content'} = 
	" idur = p3 ;\n".
	" irvbtime = p4 ;\n".
	" asig reverb garvbsig,irvbtime ;\n".
	" outs asig,asig ;\n".
	" garvbsig = 0 ;\n".
	"endin ;\n";
  $CsgObj->instruments->{$pref.'_p3_fun'} = "dur";
  $CsgObj->instruments->{$pref.'_p3_def'} = "120";
  $CsgObj->instruments->{$pref.'_p4_fun'} = "rvt";
  $CsgObj->instruments->{$pref.'_p4_def'} = "120";

  ## Now create or refresh the corresponding tab (-$pref = not XML storable).
  if (exists $CsgObj->instruments->{"I576"}) { $Orcbook->delete($pref) }
  $CsgObj->instruments->{'-'.$pref.'_tab'} = $Orcbook->add($pref, -label=>$pref, -raisecmd=>\&book_open);

  $CsgObj->instruments->{"I576"} = &Csgrouper::Datem();

  ## File name, Title, Desc, Comments text flds
  $CsgObj->instruments->{'-'.$pref.'_frame'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Frame(-borderwidth=>4, -relief=>'groove');
  $CsgObj->instruments->{'-'.$pref.'_frame'}->form(-left=>['%1',0], -right=>['%99',0], -top=>['%1',4]);
  $CsgObj->instruments->{'-'.$pref.'_path_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'File path: ' )->form(-top=>['%1',4],-left=>['%1',0]);
  $CsgObj->instruments->{'-'.$pref.'_path_entry'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->PathEntry( -textvariable=>\$CsgObj->instruments->{$pref.'_path'}, -background=>$COLOR{input_bgcolor}, -state=>'normal',  )->form(
	-left=>[$CsgObj->instruments->{'-'.$pref.'_path_label'},0]
	,-top=>['%1',4]
	,-right=>['%40',0]
  );

  $CsgObj->instruments->{'-'.$pref.'_author_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Author: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_author'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_author_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_path_entry'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_name_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Ins. name: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>\$CsgObj->instruments->{$pref.'_name'}
		,-width => 12
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'spalnumin') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_name_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_author_text'},0]
  );

  ## ### Multi choice:
	$CsgObj->instruments->{'-'.$pref.'_type_text'} =
	$CsgObj->instruments->{'-'.$pref.'_frame'}->Menubutton(
		 -borderwidth=>1
		,-background => $COLOR{cbox_bgcolor}
		,-foreground => $COLOR{cbox_fgcolor}
		,-relief=>'groove'
		,-text=>'Ins. type'
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Inst',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'ins'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'Fx',
		-variable => \$CsgObj->instruments->{$pref.'_type'}
		,-value => 'fx'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'amp',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'amp'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'ampdb',
		-variable => \$CsgObj->instruments->{$pref.'_amp_type'}
		,-value => 'ampdb'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->separator();
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cps',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cps'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'cpspch',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'cpspch'
		,-underline => 0
	);
	$CsgObj->instruments->{'-'.$pref.'_type_text'}->radiobutton(
		-label => 'midi',
		-variable => \$CsgObj->instruments->{$pref.'_freq_type'}
		,-value => 'midi'
		,-underline => 0
	);
	
  $CsgObj->instruments->{'-'.$pref.'_type_text'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
  );

  $CsgObj->instruments->{'-'.$pref.'_param_nbr'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->LabEntry(
		-label => 'Param. nbr: '
		,-labelPack => ['-side', 'left', '-anchor', 'w' ]
		#,-labelFont => '9x15bold'
		,-background => $COLOR{input_bgcolor}
		,-foreground => $COLOR{input_fgcolor}
		,-relief => 'ridge'
		,-state => 'normal'
		,-textvariable =>'1'
		,-width => 4
		,-validate => 'key'
		,-validatecommand => sub { &valid_entry($_[1],'digit') }
		,-invalidcommand => sub { }
  );
  $CsgObj->instruments->{'-'.$pref.'_param_nbr'}->form(   
		-top=>['%1',4]
		,-left=>[$CsgObj->instruments->{'-'.$pref.'_type_text'},0]
  );

  $CsgObj->instruments->{'-'.$pref.'_com_label'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Label( -textvariable=>\'Comments: ' )->form(-left=>['%1',0],-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]);
		$CsgObj->instruments->{'-'.$pref.'_com_text'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Text(-state=>'normal', -background=>$COLOR{input_bgcolor}, -height=>'2')->form(
		-left=>[$CsgObj->instruments->{'-'.$pref.'_com_label'},0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_name_text'},4]
		,-right=>['%99',0]
		## XXX WARNING wrap option produces an error when not in scrolled text.
		);
		$CsgObj->instruments->{'-'.$pref.'_com_text'}->Contents($CsgObj->instruments->{$pref.'_comment'});
		
		## Default params table  with zeroes if no previous data in i576_p4 e.g.
		$parnum = 1;
		$CsgObj->instruments->{'-'.$pref.'_table'} = $CsgObj->instruments->{'-'.$pref.'_frame'}->Table(
		-rows => 3
		,-columns => ($parnum+1)
		,-relief=>'groove'
		,-scrollbars => 'se' 
		,-fixedrows => 1
		,-fixedcolumns => 1
		,-takefocus => 'on'
  );
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(0, 0, 'ind:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(1, 0, 'fun:');
  $CsgObj->instruments->{'-'.$pref.'_table'}->put(2, 0, 'def:');
  for (my $n = 1; $n <= $parnum; $n++) {
	my $tmp_label = $CsgObj->instruments->{'-'.$pref.'_table'}->Label(-text =>"p".($n+2), -anchor => 'w', -relief =>'groove', -justify => 'left');
	my $tmp_fun = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	my $tmp_def = $CsgObj->instruments->{'-'.$pref.'_table'}->Text(-background => $COLOR{table_bgcolor}, -foreground => $COLOR{table_fgcolor}, -height=>1, -width =>4);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(0, $n, $tmp_label);
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(1, $n, $tmp_fun);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(1, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_fun'}); 
	$CsgObj->instruments->{'-'.$pref.'_table'}->put(2, $n, $tmp_def);
	$CsgObj->instruments->{'-'.$pref.'_table'}->get(2, $n)->Contents($CsgObj->instruments->{$pref.'_p'.($n+2).'_def'}); 
  }
  $CsgObj->instruments->{'-'.$pref.'_table'}->form(
		-left=>['%1',0]
		,-top=>[$CsgObj->instruments->{'-'.$pref.'_com_text'},4]
		,-right=>['%99',0]
  );

  ## Delete button. 
  $CsgObj->instruments->{'-'.$pref.'_delete_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Delete'
	  ,-state=>'disabled'
	  ,-command=>\sub { &ins_del($pref) }
  )->form(
		-right=>['%99',4]
		, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

  ## Save as button. 
  $CsgObj->instruments->{'-'.$pref.'_saveas_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
	  -background =>$COLOR{'button_bgcolor'}
	  ,-foreground =>$COLOR{'button_fgcolor'}
	  ,-text=>'Save As'
	  ,-state=>'normal'
	  ,-command=>\sub {ins_sas($pref)}
  )->form(
	-right=>[$CsgObj->instruments->{'-'.$pref.'_delete_button'},4]
	, -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
  );

	## Save changes button. 
	$CsgObj->instruments->{'-'.$pref.'_save_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Button(
		-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
		,-text=>'Update'
		,-state=>'normal'
		,-command=>\&ins_update
	)->form(
	  -right=>[$CsgObj->instruments->{'-'.$pref.'_saveas_button'},4]
	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},4]
	);

	## New ins button. 
	$CsgObj->instruments->{'-'.$pref.'_new_button'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Menubutton(
	  -text=>'New',
	  -menuitems => [
		  ['command' => 'New Ins', -command => sub { &ins_new('ins') } ],
		  ['command' => 'New FX', -command => sub { &ins_new('fx') } ],
	  ]	
		,-background =>$COLOR{'button_bgcolor'}
		,-foreground =>$COLOR{'button_fgcolor'}
	)->form(
 	  -right=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},-4]
 	  , -top=>[$CsgObj->instruments->{'-'.$pref.'_frame'},7]
 	);                 		

  ## Instrument text field (modifiable). 
  $CsgObj->instruments->{'-'.$pref.'_content_text'} = $CsgObj->instruments->{'-'.$pref.'_tab'}->Scrolled(
	'TextUndo'
	, -background=>$COLOR{input_bgcolor}
	, -foreground =>$COLOR{input_fgcolor}
	, -scrollbars => 'se' 
	, -wrap => 'word' 
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->form(
	-top=>[$CsgObj->instruments->{'-'.$pref.'_save_button'},8]
	, -left=>['%1',0], -right=>['%99',0]
	, -bottom=>['%98',0]
  );
  $CsgObj->instruments->{'-'.$pref.'_content_text'}->Contents(
	"instr ".$CsgObj->instruments->{$pref.'_id'}."\n".
	$CsgObj->instruments->{$pref.'_content'}
  );
  ## ### Now update F-tables and Global vars:
  my $orcinit = $Orcini_tw->Contents();
  my $ftb = $Ftb_tw->Contents();
  $ftb = "f 1 0 65536 10 1 ;	sine (internal).\n".$ftb if ($ftb !~ /\s*f\s+1\s+\d+.*\n/);
  $Ftb_tw->Contents($ftb);
  $orcinit = "garvbsig = 0 ;	global reverb (internal).\n".$orcinit if ($orcinit !~ /\s*garvbsig[\=\s]+.*\n/);
  $Orcini_tw->Contents($orcinit);
  $Csgrouper::DEBFLAG =  $oldebflag;
} ## END ins_def().

