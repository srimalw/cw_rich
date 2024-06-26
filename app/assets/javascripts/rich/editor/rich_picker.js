// Direct asset picker

var rich = rich || {};
rich.AssetPicker = function(){
	
};

rich.AssetPicker.prototype = {
	
	showFinder: function(dom_id, options){
		// open a popup
		var params = {};
		params.CKEditor = 'picker'; // this is not CKEditor
		params.default_style = options.default_style;
		params.allowed_styles = options.allowed_styles;
		params.insert_many = options.insert_many;
		params.type = options.type || "image";
		params.viewMode = options.view_mode || "grid";
		params.scoped = options.scoped || false;
		params.alpha = options.alpha || true;
		params.file_type = options.file_type || false;
		params.parent_id = options.parent_id || 0;
		params.folder_level = options.folder_level;
		if(params.scoped == true) {
			params.scope_type = options.scope_type
			params.scope_id = options.scope_id;
		}
		params.dom_id = dom_id;
		var url = addQueryString(options.richBrowserUrl, params );
		window.open(url, 'filebrowser', "resizable=yes,scrollbars=yes,width=860,height=500")
  },

	setAsset: function(dom_id, asset, id, type){
		var split_field_name = $(dom_id).attr('id').split('_')
		if (split_field_name[split_field_name.length - 1] == "id") {
			$(dom_id).val(id);
		} else {
			$(dom_id).val(asset);
		}

		let previewContainer = $(dom_id).siblings('.preview')[0]
		let previewElements = $(previewContainer).children()

		previewElements.each((index, element)=> {
			$(element).remove()
		})

    if(type=='image') {
			$(previewContainer).append(`<img class='rich-image-preview' src=${asset}/>`)
    }
		// if file type is not image
    else if(type=='all') {
			$(previewContainer).append(`<a href=${asset} target=_blank>attachment</a>`)
    }
  },

};

// Rich Asset input
var assetPicker = new rich.AssetPicker();