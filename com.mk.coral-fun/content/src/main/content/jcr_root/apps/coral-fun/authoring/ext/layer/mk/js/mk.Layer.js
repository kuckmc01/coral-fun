(function ($, author, mk, channel, window, undefined) {

    var name = Granite.I18n.get('MK Ultra Cool'), // public layer name
        iconClass = 'coral-Icon--campaign'; // icon to be shown in the layer switcher

    /**
     * 
     * @constructor
     */
    var MkLayer = function () {
        // Call super constructor
        this.constructor.prototype.constructor.call(this, name, iconClass);
    };

    // set generic layer as prototype for inheritance
    MkLayer.prototype = new author.Layer();

    /**
     * Determines if the layer is available for the current page
     * 
     * MSM layer: If the page is not a life copy then this layer is deactivated
     * 
     * @return {Boolean}
     */
    MkLayer.prototype.isAvailable = function() {
        return author.page && 
            author.page.info;
    };

    /**
     * Will be called when the layer gets activated
     */
    MkLayer.prototype.setUp = function () {
        // find all current editables on the page
    	var editables = author.edit.findEditables();
        author.store.set(editables);

        // activate the custom MK overlay
        author.overlayManager.setOverlayRendering(mk.Overlay);
        $.each(editables,function(i,v){
        	console.log(v.path);
        	//console.log($(+v.path + ' button'));
        });
        
        mk.helloworld();
        author.overlayManager.setup();
        author.overlayManager.reposition(true);

        // Show after the overlays are initially positioned
        setTimeout(function () {
            author.overlayManager.startObservation();
            author.overlayManager.setVisible(true);
        }, 300);
    };

    /**
     * Will be called when the layer gets deactivated
     */
    MkLayer.prototype.tearDown = function () {
        // Clean the overlays
        author.overlayManager.stopObservation();
        author.overlayManager.teardown();
        author.overlayManager.resetOverlayRendering();
        author.overlayManager.setVisible(false);

        author.store.clean();
    };

    // register at the manager
    author.layerManager.registerLayer(new MkLayer());

    // expose to namespace (in case to provide further inheritance)
    mk.Layer = MkLayer;

}(jQuery, Granite.author, aem.mk, jQuery(document), this));