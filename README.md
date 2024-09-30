# Visualenv

Store your env variables securely in images using steganography.

[Octomim](https://www.esenbil.com/octomim) is used as backend service to embed and extract hidden data.

![Sample](./stego.png)


**Embed**

```
PS D:\Projects\visualenv\windows> .\embed.ps1
Creating stego image
Response Time: 2113 ms
Getting stego image 87g2k1f086.png
```

**Extract**

```
PS D:\Projects\visualenv\windows> .\extract.ps1 87g2k1f086.png
Extracting hidden env variables using: 87g2k1f086.png
Requesting URL: https://192.168.11.111:8443/api/stego/extract/text
Request Body: {
    "file":  "87g2k1f086.png"
}
{"text":"__PSLockDownPolicy=0
ALLUSERSPROFILE=C:\ProgramData
APPDATA=C:\Users\ersin.esen\AppData\Roaming
CommonProgramFiles=C:\Program Files\Common Files
CommonProgramFiles(x86)=C:\Program Files (x86)\Common Files
CommonProgramW6432=C:\Program Files\Common Files
...
```


