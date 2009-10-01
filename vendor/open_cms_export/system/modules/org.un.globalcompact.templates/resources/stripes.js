addEvent(window, "load", do_optInit);
addEvent(window, "load", do_search_optInit);
addEvent(window, "load", dropdown_init);
addEvent(window, "load", sortables_init);

var map = '';
var map_go = false;
var orig_data = new Array();
var basic= true;
var advanced=false;

 function dropdown_init()
 {
	// Get the mapping, and the two drop downs
	map = document.getElementById('country_map');
	if( !map )
		return;
	map = eval('(' + ts_getInnerText(map) + ')');
	var parent = document.getElementById('region');
	var child = document.getElementById('country');	
	
    // Make a copy of the select list options array
    if (parent && map != 'null' && child && child.options)
	{
	  map_go = true;
      for (var i=0; i < child.options.length; i++)
	  {
        orig_data[i] = new Option();
        orig_data[i].text = child.options[i].text;

        if (child.options[i].value)
          orig_data[i].value = child.options[i].value;
        else
          orig_data[i].value = child.options[i].text;
      }	
	}
 }

 function dropdown_update()
 {
	if( !map_go )
		return;
		
	// Find parent selection
	// return region value to all when basic selected
	var basic = document.getElementById('di_basic');
	if(basic ) {
		var parent = document.getElementById('region');
		//parent.setAttribute('selectedIndex','All');
		var sel_index = parent.selectedIndex;
		//parent.setAttribute('options[ sel_index ].value','All');
		var sel_value = parent.options[ sel_index ].value;
		var child = document.getElementById('country');
	}
	else {
		var parent = document.getElementById('region');
		var sel_index = parent.selectedIndex;
		var sel_value = parent.options[ sel_index ].value;
		var child = document.getElementById('country');
	} 

	while( child.options.length > 0 )
		child.remove(0);

	  for (var i=0; i < orig_data.length; i++)
	  {
		child.options[i] = new Option();
        child.options[i].text = orig_data[i].text;

        if (orig_data[i].value)
          child.options[i].value = orig_data[i].value;
		else
          child.options[i].value = orig_data[i].text;
	  }	

	if( sel_value != 'All' )
	for( j=0; j<map.length; j++ )
		for(i=0; i < child.options.length;  i++)
			if( child.options[i].value == map[j].id )
			{
				if( sel_value != map[j].parent_id )
					child.remove(i)
				break;
			}
 }
	
	  // this function is needed to work around 
  // a bug in IE related to element attributes
  function hasClass(obj) {
     var result = false;
     if (obj.getAttributeNode("class") != null) {
         result = obj.getAttributeNode("class").value;
     }
     return result;
  }

  
 function do_jumpSubmit()
 {
   var form = document.getElementById('jumpform');
   form.submit();
 }

 
 function do_search_optInit()
 {
	var basic = document.getElementById('basicsearch');
	var advanced = document.getElementById('advancedsearch');

	if( !basic || !advanced )
		return;

	if( !advanced.checked == true )
		do_opt_searchbasic();
	else 
		do_opt_searchadvanced();
 }
 
 function do_opt_searchbasic()
 {
	var basic = document.getElementById('di_basic');
	var advanced = document.getElementById('di_advanced');
	dropdown_update();

	basic.style.display = 'block';
	advanced.style.display = 'none';
 }

 function do_opt_searchadvanced()
 {
	var basic = document.getElementById('di_basic');
	var advanced = document.getElementById('di_advanced');
	
	basic.style.display = 'none';
	advanced.style.display = 'block';
 }
 

 function do_optInit()
 {
	var biz = document.getElementById('part_biz');
	var oth = document.getElementById('part_oth');

	if( !biz || !oth )
		return;

	if( biz.checked == true )
		do_optBiz();
	else if(oth.checked == true )
		do_optOth();
	else
		do_optAll();
 }

 function do_optAll()
 {
	var biz = document.getElementById('di_biz');
	var oth = document.getElementById('di_oth');
	
	biz.style.display = 'none';
	oth.style.display = 'none';
 }
 
 function do_optBiz()
 {
	var biz = document.getElementById('di_biz');
	var oth = document.getElementById('di_oth');
	
	biz.style.display = 'block';
	oth.style.display = 'none';  
 }
 
 function do_optOth()
 {
	var biz = document.getElementById('di_biz');
	var oth = document.getElementById('di_oth');
	
	biz.style.display = 'none';
	oth.style.display = 'block';  
 }

 function stripe(table) {
	var even = false;  
    var evenColor = arguments[1] ? arguments[1] : "#e5eef0";
    var oddColor = arguments[2] ? arguments[2] : "#fff";
  
    if (! table) { return; }
    
    var tbodies = table.getElementsByTagName("tbody");

    for (var h = 0; h < tbodies.length; h++) { 
      var trs = tbodies[h].getElementsByTagName("tr");
      for (var i = 0; i < trs.length; i++) {
          var tds = trs[i].getElementsByTagName("td");
          for (var j = 0; j < tds.length; j++)
            tds[j].style.backgroundColor = even ? evenColor : oddColor;
        even =  ! even;
      }
    }
  }
  
var SORT_COLUMN_INDEX;

function sortables_init() {
    // Find all tables with class sortable and make them sortable
    if (!document.getElementsByTagName) return;
    tbls = document.getElementsByTagName("table");
    for (ti=0;ti<tbls.length;ti++) {
        thisTbl = tbls[ti];
        if (((' '+thisTbl.className+' ').indexOf("sortable") != -1) && (thisTbl.id)) {
			ts_makeSortable(thisTbl);			
            var foo = document.getElementById('s_default');
            ts_resortTable( foo.childNodes[1] );
			stripe(thisTbl);
		}
    }
}

function ts_makeSortable(table) {
    if (table.rows && table.rows.length > 0) {
        var firstRow = table.rows[0];
    }
    if (!firstRow) return;
    
    // We have a first row: assume it's the header, and make its contents clickable links
    for (var i=0;i<firstRow.cells.length;i++) {
        var cell = firstRow.cells[i];
        var txt = ts_getInnerText(cell); 
        cell.innerHTML = txt + '&nbsp;<a href="#" onclick="ts_resortTable(this);return false;"><span class="js_sortable"><img src="/dynamic/images/list_default.gif" border="0"/></span></a>';
    }
}

function ts_getInnerText(el) {
if (typeof el == "string") return el;
	if (typeof el == "undefined") { return el };
	if (el.innerText) return el.innerText;	//Not needed but it is faster
	var str = "";
	
	var cs = el.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		switch (cs[i].nodeType) {
			case 1: //ELEMENT_NODE
				str += ts_getInnerText(cs[i]);
				break;
			case 3:	//TEXT_NODE
				str += cs[i].nodeValue;
				break;
		}
	}
	return str;
}

function ts_resortTable(lnk) {
    // get the span
    var span;
    for (var ci=0;ci<lnk.childNodes.length;ci++) {
        if (lnk.childNodes[ci].tagName && lnk.childNodes[ci].tagName.toLowerCase() == 'span') span = lnk.childNodes[ci];
    }

    var spantext = ts_getInnerText(span);
    var td = lnk.parentNode;
    var column = td.cellIndex;
    var table = getParent(td,'TABLE');
    
    // Work out a type for the column
    if (table.rows.length <= 1) return;
    var itm = ts_getInnerText(table.rows[1].cells[column]);
    sortfn = ts_sort_caseinsensitive;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^\d\d[\/-]\d\d[\/-]\d\d$/)) sortfn = ts_sort_date;
    if (itm.match(/^[�$]/)) sortfn = ts_sort_currency;
    if (itm.match(/^[\d\.]+$/)) sortfn = ts_sort_numeric;
    SORT_COLUMN_INDEX = column;
    var firstRow = new Array();
    var newRows = new Array();
    for (i=0;i<table.rows[0].length;i++) { firstRow[i] = table.rows[0][i]; }
    for (j=1;j<table.rows.length;j++) { newRows[j-1] = table.rows[j]; }

    newRows.sort(sortfn);

    if (span.getAttribute("sortdir") == 'down') {
        ARROW = '<img src="/dynamic/images/list_up.gif" border="0"/>';
        newRows.reverse();
        span.setAttribute('sortdir','up');
    } else {
        ARROW = '<img src="/dynamic/images/list_down.gif" border="0"/>';
        span.setAttribute('sortdir','down');
    }
    
    // We appendChild rows that already exist to the tbody, so it moves them rather than creating new ones
    // don't do sortbottom rows
    for (i=0;i<newRows.length;i++) { if (!newRows[i].className || (newRows[i].className && (newRows[i].className.indexOf('sortbottom') == -1))) table.tBodies[0].appendChild(newRows[i]);}
    // do sortbottom rows only
    for (i=0;i<newRows.length;i++) { if (newRows[i].className && (newRows[i].className.indexOf('sortbottom') != -1)) table.tBodies[0].appendChild(newRows[i]);}
 
 
    // Delete the sort_active style off all headers
	var all_spans = document.getElementsByTagName("span");
    for (var ci=0;ci<all_spans.length;ci++)
        if (all_spans[ci].className && all_spans[ci].className.toLowerCase() == 'js_sortable') 
			all_spans[ci].innerHTML = '<img src="/dynamic/images/list_default.gif" border="0"/>';

	// Put the active arrow on the active on
    span.innerHTML = ARROW;
	
	// Redo the stripes
	stripe(table);
}

function getParent(el, pTagName) {
	if (el == null) return null;
	else if (el.nodeType == 1 && el.tagName.toLowerCase() == pTagName.toLowerCase())	// Gecko bug, supposed to be uppercase
		return el;
	else
		return getParent(el.parentNode, pTagName);
}

function ts_sort_date(a,b) {
    // y2k notes: two digit years less than 50 are treated as 20XX, greater than 50 are treated as 19XX
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa.length == 10) {
        dt1 = aa.substr(6,4)+aa.substr(3,2)+aa.substr(0,2);
    } else {
        yr = aa.substr(6,2);
        if (parseInt(yr) < 50) { yr = '20'+yr; } else { yr = '19'+yr; }
        dt1 = yr+aa.substr(3,2)+aa.substr(0,2);
    }
    if (bb.length == 10) {
        dt2 = bb.substr(6,4)+bb.substr(3,2)+bb.substr(0,2);
    } else {
        yr = bb.substr(6,2);
        if (parseInt(yr) < 50) { yr = '20'+yr; } else { yr = '19'+yr; }
        dt2 = yr+bb.substr(3,2)+bb.substr(0,2);
    }
    if (dt1==dt2) return 0;
    if (dt1<dt2) return -1;
    return 1;
}

function ts_sort_currency(a,b) { 
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).replace(/[^0-9.]/g,'');
    return parseFloat(aa) - parseFloat(bb);
}

function ts_sort_numeric(a,b) { 
    aa = parseFloat(ts_getInnerText(a.cells[SORT_COLUMN_INDEX]));
    if (isNaN(aa)) aa = 0;
    bb = parseFloat(ts_getInnerText(b.cells[SORT_COLUMN_INDEX])); 
    if (isNaN(bb)) bb = 0;
    return aa-bb;
}

function ts_sort_caseinsensitive(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]).toLowerCase();
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]).toLowerCase();
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}

function ts_sort_default(a,b) {
    aa = ts_getInnerText(a.cells[SORT_COLUMN_INDEX]);
    bb = ts_getInnerText(b.cells[SORT_COLUMN_INDEX]);
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
}


function addEvent(elm, evType, fn, useCapture)
// addEvent and removeEvent
// cross-browser event handling for IE5+,  NS6 and Mozilla
// By Scott Andrew
{
  if (elm.addEventListener){
    elm.addEventListener(evType, fn, useCapture);
    return true;
  } else if (elm.attachEvent){
    var r = elm.attachEvent("on"+evType, fn);
    return r;
  } else {
  //  alert("Handler could not be removed");
  }
} 

function validate_cop_search()
{
	var year = document.getElementById("year");
	var month = document.getElementById("month");
	var day = document.getElementById("day");
	var ok = false;
	
	if( (year.value && month.value && day.value) || (!year.value && !month.value && !day.value) )
		return true;
	
	alert("You must enter all values (YYYY/MM/DD) for the year.");		
	return false;
}