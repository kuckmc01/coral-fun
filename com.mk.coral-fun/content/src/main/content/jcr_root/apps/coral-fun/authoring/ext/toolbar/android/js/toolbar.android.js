;(function ($, author, channel, window, undefined) {

    var actionDef = {
        icon: 'coral-Icon--android',
        text: Granite.I18n.get('Android'),
        handler: function (editable, param, target) { // will be called on click
        	$('#ContentFrame').contents().find('div.media-page-content')
        	.css('background-image','url(https://rajitha4.files.wordpress.com/2014/11/android.png)');
        },
        isNonMulti: true
    };
    
    // we listen to the messaging channel
    // to figure out when a layer got activated
    channel.on('cq-layer-activated', function (ev) {
        // we continue if the user switched to the Edit layer
        if (ev.layer === 'Edit') {
            // we use the editable toolbar and register an additional action
            author.EditorFrame.editableToolbar.registerAction('ANDROID', actionDef);
        }
    });

}(jQuery, Granite.author, jQuery(document), this));
