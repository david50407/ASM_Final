#include <Windows.h>
#include <string>

extern "C"
{
	static CHAR * getLastErrorText(CHAR *,	unsigned long);

	void __stdcall showLastError()
	{
		char buf[1024];
		MessageBox(NULL, getLastErrorText(buf, sizeof(buf)), "", 0L);
	}

	// usage
	//     CHAR msgText[256];
	//     getLastErrorText(msgText,sizeof(msgText));
	static CHAR *                      //   return error message
	getLastErrorText(                  // converts "Lasr Error" code into text
	CHAR *pBuf,                        //   message buffer
	unsigned long bufSize)                     //   buffer size
	{
     unsigned int retSize;
     LPTSTR pTemp=NULL;

     if (bufSize < 16) {
          if (bufSize > 0) {
               pBuf[0]='\0';
          }
          return(pBuf);
     }
     retSize=FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER|
                           FORMAT_MESSAGE_FROM_SYSTEM|
                           FORMAT_MESSAGE_ARGUMENT_ARRAY,
                           NULL,
                           GetLastError(),
                           LANG_NEUTRAL,
                           (LPTSTR)&pTemp,
                           0,
                           NULL );
     if (!retSize || pTemp == NULL) {
          pBuf[0]='\0';
     }
     else {
          pTemp[strlen(pTemp)-2]='\0'; //remove cr and newline character
          sprintf_s(pBuf, bufSize,"%0.*s (0x%x)",bufSize-16,pTemp,GetLastError());
          LocalFree((HLOCAL)pTemp);
     }
     return(pBuf);
}
}