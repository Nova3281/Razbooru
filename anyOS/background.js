chrome.downloads.setShelfEnabled(false)

chrome.runtime.onMessage.addListener(function(msg)
	{
	switch(msg.action)
		{
		case 'save':
			chrome.downloads.download({ url: msg.url, filename: msg.filename, saveAs: true })
			break
		case 'open':
			chrome.runtime.sendNativeMessage('org.gamemage.anyos', { text: (msg.cmd || 'open')+" '"+msg.url+"'" }, function(reply)
				{
				if(typeof chrome.runtime.lastError !== 'undefined')
					{
					console.log(chrome.runtime.lastError)
					alert("Unfortantly safely opening the link didn't work.\nPlease drag and drop the link into your browser instead.\n\nWhy?\nThis app runs inside a separate session of Google Chrome with elevated permissions. Unfortunately opening any links normally would open them in the same session and give them the same permissions. The method implemented to fix this issue doesn't work on all systems yet currently.\n\nDEBUG:\n"+chrome.runtime.lastError.message)
					}
				})
			break
		}
	})
