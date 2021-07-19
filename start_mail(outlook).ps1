###############################################################
#   �������菈��
###############################################################

# �����`�F�b�N
Param($DateStr = (Get-Date).ToString('yyyyMMdd'))
try {
    $CheckDate = [DateTime]::ParseExact($DateStr, 'yyyyMMdd', $null)
} catch {
    echo 'Invalid argument'
    exit 255
}
$CachePath = 'C:\Users\������\Documents\iMacros\Downloads\' # ���t�{�񋟂̏j���t�@�C�����L���b�V������f�B���N�g��
$HolidayFile = Join-Path $CachePath holiday.csv   # �j���o�^�t�@�C����
$Limit = (Get-Date).AddMonths(-3)                 # �R�����ȏ�O�͌Â��j���o�^�t�@�C���Ƃ���

# �j���o�^�t�@�C���������A�������͏j���o�^�t�@�C���̍X�V�����Â��Ȃ����ꍇ�A�Ď擾����
if (! (Test-Path $HolidayFile) -or $Limit -gt (Get-ItemProperty $HolidayFile).LastWriteTime) {
    try {
        Invoke-WebRequest https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv -OutFile $HolidayFile
    } catch {
        echo $_.Exception.Message
        exit 250
    }
}

# �o�O�Ή��Ƃ��Ċ��S��v�ƂȂ�悤���t��","��}���i9/2�͕����ɂ�������炸9/21��9/22�̏j���Ɣ��肳�ꂽ���߁j
$CheckDate1 = (Get-Date $CheckDate).ToString('yyyy/M/d') + ","

# �j���Ƃ��ēo�^����Ă���� 0 ��ԋp���ďI��
if (Select-String -Quiet $CheckDate1 $HolidayFile) {
    exit 0
}

# �y���Ȃ� 0 ��ԋp���ďI��
$DayOfWeek = (Get-Date $CheckDate).DayOfWeek
if ($DayOfWeek -in @('Saturday', 'Sunday')) {
    exit 0
}

# �N���N�n�i12��30���`1��3���j�Ȃ� 0 ��ԋp���ďI��
$MMDD = (Get-Date $CheckDate).ToString('MMdd')
if ($MMDD -ge '1230' -or $MMDD -le '0103') {
    exit 0
} 

# ��L������ł��Ȃ���Ε����Ƃ��ď����p��

################################################################
##   Outlook ���[���ʒm����
################################################################

# Outlook�v���Z�X�̋N���`�F�b�N
$TEST =Get-Process|Where-Object {$_.Name -match "OUTLOOK"}
if ($TEST -eq $null){
    $existsOutlook = $false
}else{
    $existsOutlook = $true
    }

# �v���Z�X���N���܂��͎擾�BPowerShell���Ǘ��Ҏ��s���Ă�ƁC���ʂɊJ�����I�u�W�F�N�g����邱�Ƃ��o���Ȃ��D
if ($existsOutlook) {
    $OutlookObj = [System.Runtime.InteropServices.Marshal]::GetActiveObject("Outlook.Application")
} else {
    $OutlookObj = New-Object -ComObject Outlook.Application
    }

#����
$result_sub = Get-Content -Encoding UTF8 C:\Users\������\Documents\iMacros\Downloads\sub_start_mail.txt
$result_sub += Get-Date -Format "yyyy/MM/dd"

#�{��
$result = Get-Content -Encoding UTF8 C:\Users\������\Documents\iMacros\Downloads\body_start_mail.txt

##�V�K���[���̍쐬
$mail=$OutlookObj.CreateItem(0)
$mail.Subject = $result_sub
$mail.Body = $result | out-string
$mail.To = "�����惁�[���A�h���X��"
$mail.Cc = "��Cc���[���A�h���X��"
$mail.save()
$mail.Send()
