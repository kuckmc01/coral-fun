
;(function ($, ns, channel, window, undefined) {

    ns.boat = {};
    
    console.log(channel);
    
    console.log(window);

    console.log("js inside");

}(jQuery, Granite.author, jQuery(document), this));


console.log("js outside");
console.log(Granite.author);


