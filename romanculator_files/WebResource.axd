var HtmlControlJS = 
{
    oldOnResize: null,
    loadedFrames: {},
    resizeFrames: {},
    content: {},
    
    loadFrame: function(id, content, lcid, build)
    {
        if (! HtmlControlJS.loadedFrames[id])   // If it has already been loaded, then don't reload it.
        {
            if (content == null)
            {
                content = HtmlControlJS.content[id];
            }
            else
            {
                HtmlControlJS.content[id] = content;
            }

            try
            {
                var iframe = window.document.getElementById(id);
                if ((iframe.style.height == '0px') || (iframe.style.height == '') || (iframe.style.height == 'auto'))
                {
                    HtmlControlJS.resizeFrames[id] = true;
                }
                
                var iframeDoc = (iframe.contentWindow || iframe.contentDocument);
                if (iframeDoc.document) iframeDoc = iframeDoc.document; // if we have a window ref get a doc ref
                    
                HtmlControlJS.writeDocument(iframeDoc, content, lcid, build);
                setTimeout("HtmlControlJS.resizeFrame('"+id+"');", 0);  // delay reizeFrame() call to give FireFox a chance to load the dom.
            }
            catch(LoadException)            
            {
                setTimeout("HtmlControlJS.loadFrame('"+id+"', null, "+lcid+", '"+build+"');", 5);
                return;
            }
            
            HtmlControlJS.loadedFrames[id] = true;
            HtmlControlJS.content[id] = null;

            // Capture the window onResize event if this is the first HTML control loaded.
            //
            var size = 0;
            for(var x in HtmlControlJS.loadedFrames)
            {
                size++;
            }
            if (size == 1)
            {
                HtmlControlJS.oldOnResize = window.onresize;
                window.onresize = HtmlControlJS.onResize;
            }
        }
    },
    
    
    onResize: function()
    {
        if (typeof(HtmlControlJS.oldOnResize) == 'function')
        {
            HtmlControlJS.oldOnResize();
        }
        
        for(var id in HtmlControlJS.loadedFrames)
        {
            HtmlControlJS.resizeFrame(id);
        }
    },
    
    resizeFrame: function(id)
    {
        if (HtmlControlJS.resizeFrames[id])
        {
            var iframe = window.document.getElementById(id);
            var iframeDoc = (iframe.contentWindow || iframe.contentDocument);
            if (iframeDoc.document) iframeDoc = iframeDoc.document; // if we have a window reference get a document reference.

            if ((iframeDoc.readyState && (iframeDoc.readyState == 'complete')) || (!iframeDoc.readyState && iframeDoc.body))
            {
                var docHeight = iframeDoc.body.scrollHeight;
                iframe.style.height = docHeight + 'px';
            }
            else
            {
                setTimeout("HtmlControlJS.resizeFrame('"+id+"');", 5);    // delay reizeFrame() call to give FireFox a chance to load the dom.
                return;
            }
        }
    },
    
    writeDocument: function(doc, content, lcid, build)
    {
        doc.open();
        
        doc.writeln('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
        doc.writeln('<html xmlns="http://www.w3.org/1999/xhtml">');
        doc.writeln('<head>');
        doc.writeln('<title>none</title>');
        doc.writeln('<link type="text/css" rel="stylesheet" href="/_layouts/' + lcid + '/wh/stylesV2/masterroot.css?b='+ build +'" />');
        doc.writeln('<link type="text/css" rel="stylesheet" href="theme.css" />'); // This file is not cached, so no versioning
        doc.writeln('<base target="_parent" />');
        doc.writeln('</head>');
        doc.writeln('<body class="MSC_Body" style="border: 0px none black; margin: 0px; padding: 0px; background-color: transparent;">');
        
        doc.writeln(content);
        
        doc.writeln('</body>');
        doc.writeln('</html>');
        
        doc.close();
    }
    
};
