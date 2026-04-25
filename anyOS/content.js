if(window.location.hash === '#setup')
	{
	window.requestFileSystem = window.requestFileSystem || window.webkitRequestFileSystem
	window.requestFileSystem(window.TEMPORARY, chrome.runtime.id.length/8, function (fs)
		{
		fs.root.getFile('id', {create: true}, function(fileEntry) { fileEntry.createWriter(function(writer)
			{
			writer.onwriteend = function(error) { window.close() }
			writer.onerror    = function(error) { console.log('Write failed: ' + error.toString()) }
			writer.write(new Blob([chrome.runtime.id], {type: 'text/plain'}))
			}) })
		},
	function (error) { console.log(error) })
	}

document.addEventListener('click', function(event)
	{
	var href = event.target.href
	if(href == null) { return undefined }
	if(href.split(':')[0] === 'blob' || event.target.download !== "")
		{
		event.preventDefault()
		chrome.runtime.sendMessage( { action: 'save', url: href, filename: event.target.download } )
		}
	else if(event.target.target === '_blank')
		{
		event.preventDefault()
		chrome.runtime.sendMessage( { action: 'open', url: href } )
		}
	})

document.addEventListener('contextmenu', function(event)
	{
	var href = event.target.href
	if(href == null) { return undefined }
	if(href.split(':')[0] !== 'blob' || event.target.download !== "")
		{
		event.preventDefault()
		alert('TODO: Context menu')
		}
	})
