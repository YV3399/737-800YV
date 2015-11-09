var cdu = nil;

var CDU = {

    isRightLSK: func(lsk)
    {
        return (lsk[0] == `R`);
    },
    
    lineForLSK: func(lsk)
    {
        return (lsk[1] - `1`);
    },

    Field : {
        new : func(tag = nil, title = nil, pos = nil, rows = 1, dynamic = 0, selectable = 0)
        {
          m = {parents:[CDU.Field]};
          m._page = nil;
          m._title = title;
          
          m._selectable = selectable;
          m.tag = tag;
          m._line = 0;
          m._lineCount = rows;
          m.dynamic = dynamic;
          m.alignRight = 0;
          
          if (pos != nil) m._setFromLSK(pos);
    
          return m;
        },  
        
        createWithLSKAndTag : func(lsk, title, tag)
        {
            var m = CDU.Field.new(tag);
            m._setFromLSK(lsk);
            m._title = title;
            return m;
        },
    
        isSelectable: func { me._selectable; },
        getPage: func { me._page; },
        setPage: func(p) {  me._page = p; },
        
        firstLine: func { me._line; },
        lineCount: func { me._lineCount; },
        
        _setFromLSK: func(lsk)
        {
            me._line = CDU.lineForLSK(lsk);
            me.alignRight = CDU.isRightLSK(lsk);
            me.column = me.alignRight ? CDU.NUM_COLS - 1 : 0;
            
            # check for column offset value
            if ((size(lsk) > 2) and (lsk[2] == `+`)) {
                var offset = lsk[3] - `0`;
                me.column += me.alignRight ? -offset : offset;
            }
        },
        
        update: func(cdu)
        {            
            var visRange = me._page.visibleIndices(me);
            if (visRange == nil) return; # empty vis range, dont display at all
            
          #  debug.dump('field has visible range ', me.tag, visRange);
            var line = visRange.firstLine;
            for (var index=visRange.firstIndex; index <= visRange.lastIndex; index += 1) {
                me._displayOnLine(cdu, index, line);
                line += 1;
            }
        },
        
        # internal helper to put a particular field offset onto an
        # absolute CDU line.
        _displayOnLine: func(cdu, index, absLine)
        {
            var row = cdu.rowForLineTitle(absLine);
            var s = me.titleData(index);
        # check if we have a valid title string
            if (s and (size(s) > 0)) {
                s = me.alignRight ? s : (" " ~ s);
                cdu.setRowText(row, me.column, me.alignRight, s);
            }
            
            row += 1; # increment for data row
            cdu.setRowText(row, me.column, me.alignRight, me.data(index));
        },
        
        titleData: func(offset)
        {
            if (me._title != nil) return me._title;
            if (me.tag == nil) return ''; # not tag, no title, blank
            return me._page.titleDataForField(me.tag, offset);
        },
        
        data: func(offset)
        {
            return me._page.dataForField(me.tag, offset);
        },
        
        edit: func(offset, scratch)
        {
            if (me.tag == nil) return 0; # not editable
            return me._page.editDataForField(me.tag, offset, scratch);
        },
        
        select: func(index) {
            if (me.tag == nil) return -1; # not selectable
            return me._page.selectField(me.tag, index);
        },
        
        copyData: func(lsk)
        {
            var index = me._page.indexForLine(me, CDU.lineForLSK(lsk));
            if ((CDU.isRightLSK(lsk) != me.alignRight) or (index < 0) or (index >= me.lineCount()))
                return nil;
            
            var d = me.data(index);
            if ((d == nil) or (size(d) == 0))
                return nil;
            
        # if we contain placeholder, dont return that             
            if ((d[0] == `#`) or (substr(d, 0, 2) == '--'))
                return nil;
            
        # convert to large font, remove display data
            d = string.replace(d,'_','');
            d = string.replace(d,'~','');
            d = string.replace(d,'g','');
            
            return d;
        },
        
        enterData: func(lsk, scratch)
        {
            var index = me._page.indexForLine(me, CDU.lineForLSK(lsk));
            if ((CDU.isRightLSK(lsk) != me.alignRight) or (index < 0) or (index >= me.lineCount()))
                return -1;
            
            return me.edit(index, scratch);
        },
        
        selectData: func(lsk)
        {
            var index = me._page.indexForLine(me, CDU.lineForLSK(lsk));
            if ((CDU.isRightLSK(lsk) != me.alignRight) or (index < 0) or (index >= me.lineCount()))
                return -1;
                
            return me.select(index);
        }
    },
    
    ############################################################################
    # ScrolledField is used in MultiPages, queries some data from the model
    # and optimises updates differently
    ############################################################################
    ScrolledField: {
        new : func(tag, dynamic = 0, selectable = 0, alignRight = 0)
        {
            var base = CDU.Field.new(tag:tag, dynamic:dynamic, selectable:selectable);
            base.alignRight = alignRight;
            base.column = alignRight ? CDU.NUM_COLS - 1 : 0;
            
            m = {parents:[CDU.ScrolledField, base]};
            return m;  
        },  
        
    # our line count always comes from the model
        lineCount: func { 
            return me.getPage().getModel().lineCountFor(me.parents[1].tag);
        },
    },
    
    ############################################################################
    # Action is a simple structure with no title, always an lsk, done via 
    # callbacks.
    ############################################################################
    Action: {
      new : func(lbl, lsk, cb = nil, enableCb = nil)
      {
          m = {parents:[CDU.Action]};
          m.label = lbl;
          m.lsk = lsk;
          m._callback = cb;
          m._enabled = enableCb;
          return m;  
      },  
        
      exec: func
      {
          if (me._callback != nil) {
              me._callback();
          } else {
              debug.dump("dummy action executed:" ~ me.label);
          }
      },
      
      isEnabled: func
      {
          if (me._enabled != nil) {
              return me._enabled();
          } else {
              return 1;
          }
      },
      
      update: func(cdu)
      {
          var rightAlign = CDU.isRightLSK(me.lsk);
          var s = rightAlign ? (me.label ~ ">") : ("<" ~ me.label);
          var col = rightAlign ? CDU.NUM_COLS - 1 : 0;
          var line = CDU.lineForLSK(me.lsk);
          cdu.setRowText(cdu.rowForLine(line), col, rightAlign, s);
          return line;
      }
    },

    ############################################################################
    # Base class for page models. Routes requests to methods based on tag
    # values, but this can be over-ridden of course.
    ############################################################################
    AbstractModel : {
        
        new : func()
        {
            m = { parents:[CDU.AbstractModel]};
            return m;
        },
        
        data: func(tag, offset)
        {
            var method = "dataFor" ~ tag;
            return me._callTagMethod(method, [offset], nil);
        },
    
        editData: func(tag, offset, scratch)
        {
            var method = "edit" ~ tag;
            return me._callTagMethod(method, [scratch, offset], -1);
        },
    
        titleData: func(tag, offset)
        {
            var method = "titleFor" ~ tag;
            return me._callTagMethod(method, [offset], nil);
        },
        
        lineCountFor: func(tag) { me._callTagMethod('countFor' ~ tag, [], 0); },
        firstLineFor: func(tag) { me._callTagMethod('firstLineFor' ~ tag, [], 0); },
        select: func(tag, index) { me._callTagMethod('select' ~ tag, [index], -1); },
        
        _callTagMethod: func(name, invokeArgs, defaultResult) {
            var f = me._findMethod(name, me);
            if (f==nil) return defaultResult;
            
            var ret = call(f, invokeArgs, me, var err = []);
            if (size(err) > 0) {
                debug.dump('failure running tag method ' ~ name, err);
                return defaultResult;
            }
            
            return ret;
        },
        
        _findMethod: func(nm, obj) { 
            # local test
            if (contains(obj, nm) and (typeof(obj[nm]) == 'func')) return obj[nm];  
            if (contains(obj, 'parents')) {
                foreach (var pr; obj['parents']) {
                    var f = me._findMethod(nm, pr);
                    if (f != nil) return f; # found
                }
            }
            
            return nil;
        }
    },

    ############################################################################
    # Base class for CDU pages. You can subclass this, but probably not advised.
    # Better to define new field types or use a model to achieve what you need.
    ############################################################################
    Page : {
        new : func(owner, title = 'UNNAMED', model = nil, dynamicActions = 0)
        {
            m = { 
                parents:[CDU.Page],
                _previousPage: nil,
                _nextPage: nil,
                baseTitle: title,
                _actions: [],
                _fields: [],
                _model: model,
                _dynamicActions: dynamicActions,
                fixedSeparator: [99,99]
            };
            return m;
        },
    
    # compute our title
        title: func
        {
            # no siblings, simple
            if ((me._previousPage == nil) and (me._nextPage == nil))
                return me.baseTitle;
                
            var pgIndex = 0;
            var pgCount = 0;
            var pg = me;
        # find the group leader
            while (pg._previousPage != nil)
                pg = pg._previousPage;
        
        # walk forwards to find ourselves and the list end
            while (pg != nil) {
                if (pg == me) pgIndex = pgCount; # ourselves
                pgCount += 1;
                pg = pg._nextPage;
            }
        
        # position page index at far right (but one)
            var pgText = " ~"~(pgIndex + 1) ~ "/" ~ pgCount;
            var pgTitle = me.baseTitle;
            while(size(pgTitle) < CDU.NUM_COLS-size(pgText))
                pgTitle ~= " ";
            
            return pgTitle~pgText;
        },
        
    # fields
        getFields: func
        {
            return me._fields;
        },
        
        addField: func(fld) { me._addField(fld); },
        
        # inheritable version, so derived classes can call us safely
        _addField: func(fld)
        {
            fld.setPage(me);
            append(me._fields, fld);
        },
        
    # paging
        nextPage: func { (me._nextPage == nil) ? me._previousPage : me._nextPage;},
        previousPage: func { (me._previousPage == nil) ? me._nextPage : me._previousPage; },
        
    # actions
        getActions: func()
        {
            return me._actions;
        },
        
        addAction: func(act)
        {
            append(me._actions, act);
        },
    
        hasDynamicActions: func { me._dynamicActions; },
        refreshDynamicActions: func(cdu) {
            me._refreshDynamicActions(cdu);
        },
        
    # model data
        setModel: func(m) { me._model = m; },
        getModel: func { me._model; },
    
        titleDataForField: func(tag, offset)
        {
            if (me._model != nil) {
                var d = me._model.titleData(tag, offset);
                if (d) return d;
            }
             
            return nil;   
        },
        
        dataForField: func(tag, offset)
        {
            if (me._model != nil) {
                var d = me._model.data(tag, offset);
                if (d) return d;
            }
                
            return nil;
        },
        
        selectField: func(tag, index)
        {
            if (me._model != nil) {
                var d = me._model.select(tag, index);
                if (d >= 0) return d;
            }
                
            return -1;
        },
        
        editDataForField: func(tag, offset, scratch)
        {
            if (me._model != nil) {
                var d = me._model.editData(tag, offset, scratch);
                if (d >= 0) {
                    # found the tag, so we are done
                    return d;
                }
            }
              
            return nil;  
        },
    
    # display
        # over-rideable hook method when a page is displayed
        willDisplay: func(cdu) { 
            cdu.clearScratchpad();
        },
        
        # no-op by default, called when the page is replaced / cleared
        didUndisplay: func(cdu) { },
    
        update: func(cdu)
        {
            cdu.setRowText(0, 0, 0, me.title());
            me._updateActions(cdu);
            
            foreach (var field; me._fields) {
                field.update(cdu);
            }
        },
        
    # map field indices to on-screen lines. These are simple versions, 
    # MultiPage overrides them to implement scrolling!
        indexForLine: func(field, line) { line - field.firstLine(); },
        visibleIndices: func(field)
        {
            return { firstIndex:0, lastIndex: field.lineCount() - 1, firstLine: field.firstLine()};
        },
        
        _updateActions: func(cdu)
        {
        # track the topmost (lowest numbered) action on each side
            var leftAct = me.fixedSeparator[0];
            var rightAct = me.fixedSeparator[1];
        
            foreach (var act; me._actions)
            {
                if (!act.isEnabled())
                    continue;
                
            # display the action; returns its line for computing
            # the seperator positions.
                var line = act.update(cdu);
                     
                if (CDU.isRightLSK(act.lsk)) {
                    rightAct = math.min(rightAct, line);
                } else {
                    leftAct = math.min(leftAct, line);
                }
            }
        
            #debug.dump('action separator rows', leftAct, rightAct);
        
            if (leftAct > 0 and leftAct < 99) 
                cdu.setRowText(cdu.rowForLineTitle(leftAct), 0, 0, '------------');
        
            if (rightAct > 0 and rightAct < 99)
                cdu.setRowText(cdu.rowForLineTitle(rightAct), CDU.NUM_COLS - 1, 1, '------------');
        },
        
        _refreshDynamicActions: func(cdu)
        {
            foreach (var act; me._actions) {
                if (!act.isEnabled())
                    continue;
               act.update(cdu);
           }
        },
    },
    
    ############################################################################
    # Page with several screens of information. Only supports two columns,
    # but stacks its Fields up in the order they are added.
    ############################################################################
    MultiPage : {
        new : func(cdu, model, title, linesPerPage = 5, dynamicActions = 0)
        {
            var base = CDU.Page.new(owner:cdu, title:title, model:model, dynamicActions:dynamicActions);
            m = { parents:[CDU.MultiPage, base]};
            m._linesPerPage = linesPerPage;
            m._leftStack = [];
            m._rightStack = [];
            m._screen = 0;
            return m;
        },
        
        title: func { 
            # position page index at far right (but one)
            var pgText = " "~(me._screen + 1) ~ "/" ~ me.numPages();
            var pgTitle = me.baseTitle;
            while(size(pgTitle) < CDU.NUM_COLS-size(pgText)-1)
                pgTitle ~= " ";
            return pgTitle~pgText;
        },
        
        numPages: func
        {
            var leftRows = 0;
            foreach (var fld; me._leftStack) leftRows += me._model.lineCountFor(fld.tag);
            var rightRows = 0;
            foreach (var fld; me._rightStack) rightRows += me._model.lineCountFor(fld.tag);
            
            var totalRows = math.max(leftRows, rightRows);
            totalRows += (me._linesPerPage - 1); # round up
            return int(totalRows / me._linesPerPage);
        },
        
        addField: func(fld)
        {
            me._addField(fld);
            append(fld.alignRight ? me._rightStack : me._leftStack, fld);
        },
        
        indexForLine: func(field, line) 
        { 
            var virtualLine = line + (me._screen * me._linesPerPage);
            return virtualLine - me._model.firstLineFor(field.tag);
        },
        
        visibleIndices: func(field)
        {
            var screenOffset = (me._screen * me._linesPerPage);
            var lastVisible = screenOffset + me._linesPerPage - 1;
            
            var fieldStart = me._model.firstLineFor(field.tag);
            var fieldEnd = fieldStart + me._model.lineCountFor(field.tag) - 1;
            
        # if ranges dont overlap, return nil since field is invisible
            if ((fieldEnd < screenOffset) or (fieldStart > lastVisible)) return nil;
            
        # find smallest overlap
            var firstLine = 0;
            var fieldBase = fieldStart;
            
            if (fieldStart < screenOffset) {
                fieldStart = screenOffset;
            } else if (fieldStart > screenOffset) {
                firstLine += (fieldStart - screenOffset);
            }
            
            if (fieldEnd > lastVisible) {
                fieldEnd = lastVisible;
            }
        # package up and return
            return { firstIndex:fieldStart - fieldBase, 
                     lastIndex:fieldEnd - fieldBase, 
                     firstLine: firstLine};
        },
        
    # paging
        nextPage: func { 
            if ((me._screen += 1) >= me.numPages()) me._screen = 0;
            return me;
        },
        previousPage: func {
            if ((me._screen -= 1) < 0) me._screen = me.numPages() - 1;
            return me;
        },
    },

    canvas_settings: {
        "name": "CDU",
        "size": [512, 512],
        "view": [480, 480],
        "mipmapping": 1,
    },
    
    NUM_COLS: 24,
    NUM_ROWS: 14,      # 6 main rows, 6 title rows, page title and scratch
    MARGIN: 30,
    MARGIN_BOTTOM: 57, # needed because the screen is not a square
    
    EMPTY_FIELD4: '----',
    EMPTY_FIELD5: '-----',
    EMPTY_FIELD10: '----------',
    
    BOX2: '__',
    BOX2_1: '__._',
    BOX3: '___',
    BOX3_1: '___._',
    BOX4: '____',
    BOX5: '_____',
    
    new : func(prop1, placement)
    {
        m = { parents : [CDU]};

        m.rootNode = props.globals.initNode(prop1);
   
        m.scratch = "";
        m.scratchNode = m.rootNode.initNode("scratch", "", "STRING");
        m._canExecNode = m.rootNode.initNode("can-exec", 0, "BOOL");
        
        m._oleoSwitchNode = props.globals.getNode('instrumentation/fmc/discretes/oleo-switch-flight', 1);
        
        m._setupCanvas(placement);
        
        m._page = nil;
        m._model = nil;
        m._pages = {};
        m._model = CDU.AbstractModel.new(); # empty model for fallback
        m._dynamicFields = [];
        
        m.currTimerSelf = 0; # timer for key presses
        
        m._updateId = 0;
        
        return m;
    },
    
    _setupCanvas: func(placement)
    {
        me._canvas = canvas.new(CDU.canvas_settings);        
        var text_style = {
            'font': "BoeingCDU-Large.ttf",
            'character-size': 28,
            'alignment': 'left-bottom'
        };
        var text_style_s = {
            'font': "BoeingCDU-Small.ttf",
            'character-size': 28,
            'alignment': 'left-bottom'
        };
        
        var cduNode = props.globals.getNode('/instrumentation/cdu/', 1);
        cduNode.initNode('brightness-norm', 0.5, 'DOUBLE');
        
        var displayType = getprop('/instrumentation/cdu/settings/display');
        if (displayType == 'crt')
            me._canvas.setColorBackground(0.0, 0.05, 0.0);
        else
            me._canvas.setColorBackground(0.05, 0.05, 0.05);
        
        me._canvas.addPlacement(placement);
        me._scene = me._canvas.createGroup();
        me._scene.setTranslation(CDU.MARGIN, CDU.MARGIN);
        
        # create line elements
        me._texts = [];
        me._texts_s = [];
        
        var rowHeight = CDU.canvas_settings.view[1] - (CDU.MARGIN * 2 + CDU.MARGIN_BOTTOM);
        var cellH = rowHeight / CDU.NUM_ROWS;
        
        for (var r=0; r<CDU.NUM_ROWS; r = r+1) {
            var txt = me._scene.createChild("text");
            
            txt._node.setValues(text_style);
            
            if (displayType == 'crt')
                txt.setColor(0,1,0);
            else
                txt.setColor(0.9,0.9,0.9);
                
            txt.setTranslation(0.0, (r + 1.2) * cellH);
            append(me._texts, txt);
            
            var txt_s = me._scene.createChild("text");
            
            txt_s._node.setValues(text_style_s);
            
            if (displayType == 'crt')
                txt_s.setColor(0,1,0);
            else
                txt_s.setColor(0.9,0.9,0.9);
            
            txt_s.setTranslation(0.0, (r + 1.2) * cellH);
            append(me._texts_s, txt_s);
        }
    },
    
    rowForLine: func(line)
    {
        return (line * 2) + 2;
    },
    
    rowForLineTitle: func(line)
    {
        return (line * 2) + 1;
    },
    
    displayPageByTag: func(tag)
    {
        if (!contains(me._pages, tag)) {
            debug.dump("no page with tag:" ~ tag);
            return;
        }
        
        var pg = me._pages[tag];
    # check if we're in flight mode
        var inflight = (me._oleoSwitchNode.getValue() == 1);
        if (inflight and contains(me._pages, tag ~ '-inflight')) {
            pg =  me._pages[tag ~ '-inflight'];
        }
        
        me.displayPage(pg);
    },
    
    addPage: func(pg, tag)
    {
        me._pages[tag] = pg;
    },
    
    addPageWithFlightVariant: func(tag, preflight, flight)
    {
        me._pages[tag] = preflight;
        me._pages[tag ~ '-inflight'] = flight;
    },
    
    displayPage: func(pg)
    {
        if (pg != nil) pg.willDisplay(me);
        var oldPage = me._page;
        me._page = pg;
        me._refresh();
        if (oldPage != nil) oldPage.didUndisplay(me);
    },
    
    _refresh: func()
    {
        var pg = me._page;
        me.cleanup();
        if (pg == nil) return;
        
        pg.update(me);
        me._dynamicFields = [];
        
        foreach (var field; pg.getFields()) {
            if (field.dynamic)
                append(me._dynamicFields, field);   
        }
        
        if (pg.hasDynamicActions() or (size(me._dynamicFields) > 0)) {
            # only update if we have dynamic fields/actions
            me._startUpdates();
        }
    },
    
    setRowText: func(row, col, alignRight, text)
    {
        # check for nil text or empty string
        (typeof(text) == 'scalar') or return;
        
        if ((row < 0) or (row >= CDU.NUM_ROWS)) {
            debug.die('invalid row index requested', row, col, text);
            return;
        }
        
        text = text ~ ''; # force stringificaton
        
        # split large and small font
        var textS = "";
        var textL = "";
        var text1 = split('!',text);
        foreach(var textItem; text1) {
            var text2 = split('~',textItem);
            textL ~= text2[0];
            while (size(textS) < size(textL))
                textS ~= ' ';
            if (size(text2) > 1)
                textS ~= text2[1];
            while (size(textL) < size(textS))
                textL ~= ' ';
        }
        
        var canavasTextL = me._texts[row];
        var charsL = canavasTextL.get('text') or "";
        var sz = size(textL);
        
        if (alignRight)
            colL = col - (sz - 1); # find left-most column
        else
            colL = col;
    
    # find left portion, pad with spaces to position

        var lpieceL = substr(charsL, 0, colL);
        while (size(lpieceL) < colL) {
            lpieceL = lpieceL ~ ' ';
        }
        
        var rpieceL = '';
    # preserve protion to the right of our insert
        if (size(charsL) > (colL + sz)) {
            rpieceL = substr(charsL, colL + sz);
        }
        
        canavasTextL.setText(lpieceL ~ textL ~ rpieceL);
        
        var canavasTextS = me._texts_s[row];
        var charsS = canavasTextS.get('text') or "";
        var sz = size(textS);
        
        if (alignRight)
            colS = col - (sz -1); # find left-most column
        else
            colS = col;
    
    # find left portion, pad with spaces to position

        var lpieceS = substr(charsS, 0, colS);
        while (size(lpieceS) < colS) {
            lpieceS = lpieceS ~ ' ';
        }
        
        var rpieceS = '';
    # preserve protion to the right of our insert
        if (size(charsS) > (colS + sz)) {
            rpieceS = substr(charsS, colS + sz);
        }
        
        canavasTextS.setText(lpieceS ~ textS ~ rpieceS);
    },
    
    clearRowText: func(row)
    {
        me._texts[row].setText('');
        me._texts_s[row].setText('');
    },
    
    cleanup: func
    {
        for (r=0; r<CDU.NUM_ROWS; r=r+1)
            me.clearRowText(r);
    },
    
    _startUpdates: func
    {
        me._updateId += 1;
        settimer(func me._update(me._updateId), 1.0);
    },
    
    _update: func(upId)
    {
        upId == me._updateId or return;
        me._page.hasDynamicActions() or (size(me._dynamicFields) > 0) or return;
            
        if (me._page.hasDynamicActions()) {
            me._page.refreshDynamicActions(me);
        
        }
        
        foreach(var df; me._dynamicFields) {
            df.update(me);
        }
        
        settimer(func me._update(me._updateId), 1.0);
    },
     
     setExecCallback: func(execCb)
     {
         me._execCallback = execCb;
         # show the lamp
         me._canExecNode.setValue((execCb != nil));
     },
     
################################################
# data formatters
     
     formatLatitude: func(lat)
     {
         var north = (lat >= 0.0);
         var latDeg = int(lat);
         var latMinutes = math.abs(lat - latDeg) * 60;
         return sprintf('%s%02dg%04.1f', north ? "N" : "S", abs(latDeg), latMinutes);
     },
     
     formatLongitude: func(lon)
     {
          var east = (lon >= 0.0);
          var lonDeg = int(lon);
          var lonMinutes = math.abs(lon - lonDeg) * 60;
          sprintf("%s%03dg%04.1f", east ? 'E' : 'W', abs(lonDeg), lonMinutes);        
     },
     
     formatLatLonString: func(obj)
     {
         var lat = 0;
         var lon = 0;
         if (isa(obj, geo.Coord)) {
             lat = obj.lat();
             lon = obj.lon();
         } else {
             lat = obj.lat;
             lon = obj.lon;
         }
         
         return me.formatLatitude(lat) ~ ' ' ~ me.formatLongitude(lon);    
     },
     
     formatAltitude: func(altFt)
     {
         if (altFt < -100) return CDU.EMPTY_FIELD5;
         
         var flightlLevel = int(altFt/ 100);
         if (flightlLevel >= 180) return sprintf('FL%3d', flightlLevel);
         return flightlLevel * 100;
     },
     
     parseAltitude: func(altString)
     {
       var sz = size(altString);
       if ((sz == 5) and (substr(altString, 0, 2) == 'FL')) {
           altString = substr(altString, 2);
           sz = 3;
       }
       
       if ((sz < 3) or (sz > 5)) return -9999;
       if (sz == 3) return num(altString) * 100;
       return num(altString);  
     },
     
     formatBearingSpeed: func(brg, spd)
     {
         if ((brg < 0) or (spd < 0)) return '---g/---';
         return sprintf('%03dg/%03d', brg, spd);
     },
     
     _farenheitToCelsius: func(f) { (f - 32.0) / 1.8; },
     
     parseTemperatureAsCelsius: func(input)
     {
         # if default is F, need to tweak this
         var isFarenheit = 0;
         var s = string.trim(input);
         var lastChar = s[size(s) - 1];
         if (string.isalpha(lastChar)) {
             isFarenheit = (lastChar == 'F');
             s = substr(s, 0, size(s) - 1); # drop final char
         }
         
         var t = num(s);
         return isFarenheit ? _farenheitToCelsius(t) : t;
     },
     
     # dual field rules: enter both with a seperating '/'.
     # if there's no slash, it's the outboard field
     # to enter only the inboard field, there must be a preceeding slash
     # returns a two element array, with outboard element at 0, inboard at 1
     # missing elements are nil.
     parseDualFieldInput: func(input)
     {
         var s = string.trim(input);
         if (size(s) <= 0) return [nil,nil]; # empty input string
         
         var slashPos = find('/', s);
         if (slashPos < 0) return [s, nil]; # no slash, outboard only
         if (slashPos == 0) return [nil, substr(s, 1)]; # leading slash, inboard only
         return [substr(s, 0, slashPos), substr(s, slashPos + 1)];
     },
     
     formatMagVar: func(magvarDeg)
     {
         var east = (magvarDeg > 0);
         sprintf('%s%3d', east ? 'E':'W', abs(magvarDeg));
     },
     
     formatWayptSpeedAltitude: func(wp)
     {
         if (wpt==nil) return nil;
             
         var altConstraintType = wp.alt_cstr_type;
         var speedConstraintType = wp.speed_cstr_type;
        
         var altConstraint = '      '; # six spaces
         if (altConstraintType != nil)
             altConstraint = formatAltRestriction(wp);
        
         var speedConstraint = '';
         if (speedConstraintType != nil) {
             if (speedConstraintType == 'at') speedConstraint = wp.speed_cstr; 
             if (speedConstraintType == 'above') speedConstraint = wp.speed_cstr ~ 'A'; 
             if (speedConstraintType == 'below') speedConstraint = wp.speed_cstr ~ 'B'; 
             if (speedConstraintType == 'mach') speedConstraint = sprintf('.%3d', wp.speed_cstr / 1000);
         }
        
         return speed_cstr ~ '/' ~ altConstraint;
     },
     
     formatAltRestriction: func(wp)
     {
         if ((wp == nil) or (wp.alt_cstr_type == nil)) return nil;
         s = me.formatAltitude(wp.alt_cstr);
         if (altConstraintType == 'at') s ~= ' '; 
         if (altConstraintType == 'above') s ~= 'A'; 
         if (altConstraintType == 'below') s ~= 'B';
         return s;
     },
     
# button / LSK functions
    lsk: func(ident)
    {
        # check page action map for LSKs
        foreach (var act; me._page.getActions())
        {
            if (!act.isEnabled()) continue;
                
            if (act.lsk == ident) {
                act.exec();
                return;
            }
        }
        
        foreach (var fld; me._page.getFields())
        {
            if (!fld.isSelectable()) continue;
            if (fld.selectData(ident) >= 0) {
                me._refresh();
                return;
            }
        }
        
        if (size(me.scratch) > 0) {
            foreach (var fld; me._page.getFields())
            {
                var d = fld.enterData(ident, me.scratch);
                if (d == 1) {
                    me._updateScratch("");
                    me._refresh();
                    return;
                } elsif (d == 0) {
                    debug.dump("data validation error");
                    return;
                }
            }
        } else {
            foreach (var fld; me._page.getFields())
            {
                var d = fld.copyData(ident);
                if (d != nil) {
                    me._updateScratch(d);
                    return;
                }
            }
        }
        
        debug.dump('no action found for LSK');
    },
    
    button_init_ref: func
    {
        me.displayPageByTag("init-ref");
    },
    
    button_exec: func
    {
        if (me._execCallback == nil) {
            debug.dump('nothing to execute');
            return;
        }
        
        var cb = me._execCallback;
        me._execCallback = nil;
        me._canExecNode.setValue(0);
        
        cb();
        me._refresh();
    },
    
    button_route: func
    {
        me.displayPageByTag("route");
    },
    
    button_legs: func
    {
        me.displayPageByTag("legs");
    },
    
    button_vnav: func
    {
        me.displayPageByTag("vnav");
    },
    
    button_nav_radios: func
    {
        me.displayPageByTag("nav-radios");
    },
    
    button_menu: func
    {
        me.displayPageByTag("menu");
    },
    
    button_dep_arr: func
    {
        me.displayPageByTag("departure-arrival");
    },
# page navigation
    prev_page: func
    {
        var pg = me._page.previousPage();
        if (pg != nil) {
            me.displayPage(pg, 1);
        } else {
            debug.dump('no prev page');
        }
    },
    
    next_page: func
    {
        var pg = me._page.nextPage();
        if (pg != nil) {
            me.displayPage(pg, 1);
        } else {
            debug.dump('no next page');
        }
    },
    
# scratch manipulation
    _updateScratch: func(newData)
    {
        me.scratch = newData;
        me.scratchNode.setValue(newData);
        
        me.clearRowText(CDU.NUM_ROWS - 1);
        me.setRowText(CDU.NUM_ROWS - 1, 0, 0, newData);
    },

    input: func(data)
    {
        if (size(me.scratch) < CDU.NUM_COLS)
            me._updateScratch(me.scratch ~ data);
    },
    
    plusminus: func
    {
        var end = size(me.scratch);
        var lastchar = substr(me.scratch,end-1,end);
        if (lastchar == '+')
            me._updateScratch(substr(me.scratch,0,end-1)~'-');
        elsif (lastchar == '-')
            me._updateScratch(substr(me.scratch,0,end-1)~'+');
        else
            me.input('-');
    },
    
    delete : func
    {
        if (size(me.scratch) == 0)
            me._updateScratch('DELETE');
    },
    
    clear : func
    {
        # Remove last character
        me._updateScratch(substr(me.scratch, 0, size(me.scratch) - 1));
        
        # Clear entire scratchpad when press and hold for 1 sec
        me.clearTimer = maketimer(1.0, func me._updateScratch(''));
        me.clearTimer.start();
    },
    
    clearRelease : func
    {
        me.clearTimer.stop();
    },
    
    message : func(msg)
    {
        cdu._updateScratch(msg);
    },
    
    getScratchpad: func { me.scratch; },
    
    setScratchpad: func(x)
    {
        me._updateScratch(x);
    },
    
    clearScratchpad : func
    {
        me._updateScratch("");
    },
    
##################################
    StaticField : {
        new: func(pos, title = nil, data = nil)
        {
          m = {parents: [CDU.StaticField, CDU.Field.new(title:title, pos:pos)]};
          m._data = data;
          return m;
        },
        
        
        data: func(offset)
        {
            return me._data;
        }
    },
    
##################################
    NasalField : {
        new: func(pos, title, readCb, writeCb = nil)
        {
          m = {parents: [CDU.NasalField, CDU.Field.new(title:title, pos:pos)]};
          m._readCallback = readCb;
          m._writeCallback = writeCb;
          return m;
        },
        
        data: func(offset)
        {
            return me._readCallback(me.tag);
        },
        
        edit: func(offset, scratch)
        {
            if (me._writeCallback == nil) {
                debug.dump("field has no write callback");
                return 0;
            }
            
            return me._writeCallback(scratch);
        }
    },   
    
##################################
    PropField : {
        new: func(pos, prop, title = nil)
        {
          m = {parents: [CDU.PropField, CDU.Field.new(title:title, pos:pos)]};
          m._prop = prop;
          return m;
        },
        
        data: func(offset)
        {
            return getprop(me._prop);
        }
    },
    
    EditablePropField : {
        new: func(pos, prop, title = nil)
        {
          m = {parents: [CDU.EditablePropField, CDU.PropField.new(pos:pos, title:title, prop:prop)]};
          return m;
        },
        
        edit: func(offset, scratch)
        {
            setprop(me._prop, scratch);
            return 1;
        }
    },
    
#############
    linkPages: func(pages)
    {
        for (var index=0; index < size(pages); index +=1) {
            if (index > 0)
                pages[index]._previousPage = pages[index - 1];
        
            if (index < (size(pages) - 1))
                pages[index]._nextPage = pages[index + 1];
        }
    }, 
};


reload_CDU_pages = func 
{    
    debug.dump('loading CDU pages');
    
    cdu.displayPage(nil); # force existing page to be undisplayed cleanly
    
    # make the cdu instance available inside the module namespace
    # we are going to load into.
    # for a reload this also wipes the existing namespace, which we want
    globals['cdu_NS'] = { cdu: cdu, CDU:CDU };

    var settings = props.globals.getNode('/instrumentation/cdu/settings');
    foreach (var path; settings.getChildren('page')) {        
        # resolve the path in FG_ROOT, and --fg-aircraft dir, etc
        var abspath = resolvepath(path.getValue());
        if (io.stat(abspath) == nil) {
            debug.dump('CDU page not found:', path.getValue(), abspath);
            continue;
        }

        # load pages code into a seperate namespace which we defined above
        # also means we can clean out that namespace later
        io.load_nasal(abspath, 'cdu_NS');
    }

    cdu.displayPageByTag(getprop('/instrumentation/cdu/settings/boot-page'));
};

setlistener("/nasal/canvas/loaded", func 
{
    # create base CDU
    cdu = CDU.new('/instrumentation/cdu', {"node": "CDUscreen"});
    reload_CDU_pages();
}, 1);