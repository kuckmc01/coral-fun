;(function ($, author, channel, window, undefined) {

    var actionDef = {
        icon: 'coral-Icon--apple',
        text: Granite.I18n.get('Apple'),
        handler: function (editable, param, target) { // will be called on click
        	$('#ContentFrame').contents().find('div.media-page-content')
        	.css('background-image','url(http://png-5.findicons.com/files/icons/59/crystal_bw/128/apple.png)');
        },
        isNonMulti: true
    };
    
    // we listen to the messaging channel
    // to figure out when a layer got activated
    channel.on('cq-layer-activated', function (ev) {
        // we continue if the user switched to the Edit layer
        if (ev.layer === 'Edit') {
            // we use the editable toolbar and register an additional action
            author.EditorFrame.editableToolbar.registerAction('APPLE', actionDef);
        }
    });

}(jQuery, Granite.author, jQuery(document), this));
