const favLangFileProvider = () => {
	
	////////////////////////////////////////////// HERE ALL REGION BY LANG REFINEMENTS /////////////////////////////////////////	
	let _FAVLANG_TAB_ = {};	
	//------------------------------------------------------- en refinements -------------------------------------------------//
    _FAVLANG_TAB_['en_GB'] = 'en_GB';      //For en_GB uses en_GB_jpslang.json
    _FAVLANG_TAB_['en\w*'] = 'en_US';      //For any other en_XX uses en_US_jpslang.json
	//------------------------------------------------------- es refinements -------------------------------------------------//
    _FAVLANG_TAB_['es\w*'] = 'es_ES';      //For any es_XX uses es_ES_jpslang.json
	//------------------------------------------------------- fr refinements -------------------------------------------------//
    _FAVLANG_TAB_['fr\w*'] = 'fr_FR';      //For any fr_XX uses fr_FR_jpslang.json
	//------------------------------------------------------- fr refinements -------------------------------------------------//
    _FAVLANG_TAB_['de\w*'] = 'de_DE';      //For any de_XX uses de_DE_jpslang.json
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	const lookup = (str = "", o = {}) =>
	  ( Object
		  .entries (o)
		  .find (([ k, _ ]) => (new RegExp (k)) .test (str))
		  || []
	  )[1]

    const getSLangFile = (cookie_lan_key) => {		
		
        var cookies = document.cookie;
		var rx = new RegExp(cookie_lan_key+'=(\\w+)');
		var arr = rx.exec(cookies);
        var lang = arr[1];
		var langfame= '<script src="app/langs/tr/';
		var rfndLang = lookup(lang,_FAVLANG_TAB_);
		
		if (rfndLang){ lang = rfndLang;}
		
		langfame = langfame + lang + '_jpslang.json"><\/script>';
				
        return langfame;

    }

    // Using the "return" keyword, you can control what gets
    // exposed and what gets hidden.
    return {
        getSLangFile
    }	
};