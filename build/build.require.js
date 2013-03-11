({
    appDir: "../www/"
,	baseUrl: "scripts"
,	dir: "../www-release/"
,	modules: [
        {
            name: "pages/index"
        }
    ]
,	pragmas: {
		// whether or not to include unit tests on a production build
		tests: false
	}
//,    optimize: "closure"
,	optimize: "none"
})
