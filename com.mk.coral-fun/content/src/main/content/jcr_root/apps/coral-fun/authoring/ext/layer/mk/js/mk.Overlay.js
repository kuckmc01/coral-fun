(function ($, author, mk, channel, window, undefined) {


    /**
     * [MsmOverlay description]
     * @param {Editable} editable
     * @param {jQuery} container DOM element where the overlay should be rendered
     */
    var MkOverlay = function (editable, container) {
        // never save reference for editable
        if (!editable || !container) { // allows the constructor to be used seamlessly as prototype
            return;
        }
        var dom = this.render(editable);

        container.append(dom);

    };

    // inherit from default Overlay
    MkOverlay.prototype = new author.Overlay();

    /**
     * custom rendering for the Overlay
     * @param  {Editable} editable
     * @return {jQuery} created DOM element for Overlay
     */
    MkOverlay.prototype.render = function (editable) {
    	
    	// i can access methods from mk.fn.js if i want to
    	
        var icon,
            mkStatus = editable.config['dialog'],
            dom = this.constructor.prototype.render.apply(this, arguments);

        if (mkStatus) {
            // add icons
            // add icon to the overlay
        	$('<button/>',{'class':'custom-gear'}).text('click this').appendTo(dom);
           /** $('<i/>', {
                'class': 'coral-Icon coral-Icon--gear'
            }).appendTo(dom);
            **/
        	
        }
        
        return dom;
    };

    /**
     * Custom positioning (unused in this example - we call the prototypes default)
     * @param  {Editable} editable
     * @param  {Editable} parent
     */
    MkOverlay.prototype.position = function (editable, parent) {
        this.constructor.prototype.position.apply(this, arguments);
    };

    /**
     * Custom remove (unused in this example - we call the prototypes default)
     */
    MkOverlay.prototype.remove = function () {
        this.constructor.prototype.remove.apply(this, arguments);
    };
    

    // expose to namespace
    mk.Overlay = MkOverlay;

}(jQuery, Granite.author, aem.mk, jQuery(document), this));