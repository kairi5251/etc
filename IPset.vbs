'###### IP�A�h���X���Œ�ɂ���X�N���v�g ######
Option Explicit

Dim WMI, OS, Value, Shell

do while WScript.Arguments.Count = 0 and WScript.Version >= 5.7
    '##### WScript5.7 �܂��� Vista �ȏォ���`�F�b�N
    Set WMI = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
    Set OS = WMI.ExecQuery("SELECT *FROM Win32_OperatingSystem")
    For Each Value in OS
        if left(Value.Version, 3) < 6.0 then exit do
    Next

    '##### �Ǘ��Ҍ����Ŏ��s
    Set Shell = CreateObject("Shell.Application")
    Shell.ShellExecute "wscript.exe", """" & WScript.ScriptFullName & """ uac", "", "runas"
    WScript.Quit
loop

Dim objShell, iName, i, WSHShell, networks, Item, wShell
Dim oWshShell, owShell, oExec
Set objShell = CreateObject("Shell.Application")


'##### ���j���[�I��
Dim d
Dim menu

Const Title = "���j���["

Set d = CreateObject("htmlfile")
'##### �|�b�v�A�b�v�p���荞�ݏ���(���j���[�̃|�b�v�A�b�v���őO�ʂɕ\�����邽�߂̑O�i�����j
d.parentWindow.setTimeout GetRef("SetWindow"),100

'##### ���j���[��ʕ\��
menu = InputBox("���j���[��I�����Ă��������B" & vbCrLf & vbCrLf & "1.IP�A�h���X�m�F" & vbCrLf & vbCrLf & "2.IP�A�h���X�ύX" & vbCrLf & vbLf & "3.DHCP�L����",Title,2)

'##### �n���h���擾
Sub SetWindow()
    Dim Application
    Dim hwnd

    Set Application = CreateObject("Excel.Application")

    hwnd=Application.ExecuteExcel4Macro("CALL(""user32"",""FindWindowA"",""JJC"",0,""" & Title & """)")

    '##### �n���h�����擾�ł�����SetWindowPos�Ń��j���[��ʂ��őO�ʂɕ\��
    If hwnd <> 0 then
        Application.ExecuteExcel4Macro("CALL(""user32"",""SetWindowPos"",""JJJJJJJJ""," & hwnd & ",-1,0,0,0,0,3)")
    Else
        MsgBox "�n���h�����擾�ł��܂���ł����B"
    End If

    Set Application = Nothing
End Sub

'##### �L�����Z���{�^������
If IsEmpty(menu) Then
    MsgBox "�L�����Z�����܂����B"
    WScript.Quit
End If

'##### ���j���[�̓��̓`�F�b�N
Dim loopflag
loopflag = 1

Do while loopflag = 1
    '##### �l�̓��͂Ȃ�
    If Len(menu) = 0 Then
        MsgBox "�l�����͂���Ă��܂���B"
        menu = InputBox("���j���[��I�����Ă��������B" & vbCrLf & vbCrLf & "1.IP�A�h���X�m�F" & vbCrLf & vbCrLf & "2.IP�A�h���X�ύX" & vbCrLf & vbLf & "3.DHCP�L����",Title,2)
        If IsEmpty(menu) Then
            MsgBox "�L�����Z�����܂����B"
            WScript.Quit
        End If

    '##### ���l�ȊO�̓���
    Else If Not IsNumeric(menu) Then
        MsgBox "�ԍ�����͂��Ă��������B"
        menu = InputBox("���j���[��I�����Ă��������B" & vbCrLf & vbCrLf & "1.IP�A�h���X�m�F" & vbCrLf & vbCrLf & "2.IP�A�h���X�ύX" & vbCrLf & vbLf & "3.DHCP�L����",Title,2)
        If IsEmpty(menu) Then
            MsgBox "�L�����Z�����܂����B"
            WScript.Quit
        End If

    '##### ���l�i�͈͊O�j�̓���
    Else If CDbl(menu) > 5 Or CDbl(menu) < 1 Then
        MsgBox "�\�����ꂽ�͈͓��̔ԍ�����͂��Ă��������B"
        menu = InputBox("���j���[��I�����Ă��������B" & vbCrLf & vbCrLf & "1.IP�A�h���X�m�F" & vbCrLf & vbCrLf & "2.IP�A�h���X�ύX" & vbCrLf & vbLf & "3.DHCP�L����",Title,2)
        If IsEmpty(menu) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
        End If
    '##### ��L�ȊO�i����l�j
    Else
        loopflag = 0
        Exit Do
    End If
    End If
    End If
Loop

'##### �l�b�g���[�N�J�[�h���擾
Set networks = objShell.Namespace(&H31&)'NETWORK_CONNECTIONS

'##### NIC�I���_�C�A���O�ɕ\������ As String

iName = ""

'##### �l�b�g���[�N�J�[�h���̔z��

Dim iNameAry()

ReDim iNameAry(networks.Items.Count)

i=0

For Each Item in networks.Items

'##### �l�b�g���[�N�A�_�v�^�����擾

iName = iName & vbCrLf & i & ": """ & Item.Name & """"

iNameAry(i) = """" & Item.Name & """"

i=i+1

Next

'##### NIC����������ꍇ�̕ϐ���`
Dim nicSelect

'##### ���sIP�A�h���X�A�T�u�l�b�g�}�X�N�擾
Dim qu,cl,swbe,service,OldIP,OldMsk
Set swbe = WScript.CreateObject("WbemScripting.SWbemLocator")
Set service = swbe.ConnectServer
Set qu = service.ExecQuery("Select * From Win32_NetworkAdapterConfiguration where IPEnabled='true'")
For Each cl In qu
    OldIP = cl.IPAddress(0)
    OldMsk = cl.IPSubnet(0)
Next

'##### ���j���[�ʏ���
Select Case menu
    '##### IP�A�h���X�m�F
    Case    1
        '##### IP�A�h���X�\��
        Set WSHShell = WScript.CreateObject("WScript.Shell")
        Set oExec = WshShell.Exec("netsh interface ipv4 show config")
        WScript.echo oExec.StdOut.ReadAll

    '##### IP�A�h���X�ύX
    Case    2
        If networks.Items.Count > 1 Then
            '##### ���j���[�\��
            nicSelect = InputBox("�ݒ肷��l�b�g���[�N�J�[�h�̐�������͂���OK�����I��ł��������B(0�`" & networks.Items.Count-1 & "�̒l)" & vbCrLf & iName,Title,1)
            '##### �L�����Z���{�^������
            If IsEmpty(nicSelect ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
            
            '##### ���̓`�F�b�N
            loopflag = 1
            Do while loopflag = 1
                '##### �l�̓��͂Ȃ�
                If Len(nicSelect) = 0 Then
                    MsgBox "�l�����͂���Ă��܂���B"
                    nicSelect = InputBox("�ݒ肷��l�b�g���[�N�J�[�h�̐�������͂���OK�����I��ł��������B(0�`" & networks.Items.Count-1 & "�̒l)" & vbCrLf & iName,Title,1)
                    If IsEmpty(nicSelect) Then
                        MsgBox "�L�����Z�����܂����B"
                        WScript.Quit
                    End If
                '##### ���l�ȊO�̓���
                Else If Not IsNumeric(nicSelect) Then
                    MsgBox "�ԍ�����͂��Ă��������B"
                    nicSelect = InputBox("�ݒ肷��l�b�g���[�N�J�[�h�̐�������͂���OK�����I��ł��������B(0�`" & networks.Items.Count-1 & "�̒l)" & vbCrLf & iName,Title,1)
                    If IsEmpty(nicSelect) Then
                        MsgBox "�L�����Z�����܂����B"
                        WScript.Quit
                    End If
                '##### ���l�i�͈͊O�j�̓���
                ElseIf CDbl(nicSelect) > (networks.Items.Count-1) Or nicSelect*1000 Mod 1000 <> 0 Or CDbl(nicSelect) < 0 Then
                    MsgBox "�\�����ꂽ�͈͓��̔ԍ�����͂��Ă��������B"
                    nicSelect = InputBox("�ݒ肷��l�b�g���[�N�J�[�h�̐�������͂���OK�����I��ł��������B(0�`" & networks.Items.Count-1 & "�̒l)" & vbCrLf & iName,Title,1)
                    If IsEmpty(nicSelect) Then
                        MsgBox "�L�����Z�����܂����B"
                        WScript.Quit
                    End If
                '##### ��L�ȊO�i����l�j
                Else
                    loopflag = 0
                    Exit Do
                End If
                End If
            Loop
        End If

        '##### �l�b�g���[�N�ݒ����
        Const Title1 = "IP�A�h���X"
        Const Title2 = "�T�u�l�b�g�}�X�N"
        Const Title3 = "�f�t�H���g�Q�[�g�E�F�C"
        Const Title4 = "DNS�T�[�o�[1"
        Const Title5 = "DNS�T�[�o�[2"
        
        Dim NewIP,NewMsk,NewGWY,DnsSv1,DnsSv2
        
        '##### IP�A�h���X�ݒ�
        loopflag = 1
        Do while loopflag = 1
            NewIP = InputBox("IP�A�h���X����͂��Ă��������B" & vbCrLf & "��F10.255.8.101",Title1,"10.255.8.101")
            '##### �L�����Z������
            If IsEmpty(NewIP ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
            '##### �l�̓��͂Ȃ�
            If Len(NewIP) = 0 Then
                MsgBox "�l�����͂���Ă��܂���B"
                NewIP = InputBox("IP�A�h���X����͂��Ă��������B" & vbCrLf & "��F10.255.8.101",Title1,"10.255.8.101")
                If IsEmpty(NewIP) Then
                    MsgBox "�L�����Z�����܂����B"
                    WScript.Quit
                End If
            '##### ��L�ȊO�i����l�j
            Else
                loopflag = 0
                Exit Do
            End If
        Loop
        
        '##### �T�u�l�b�g�}�X�N�ݒ�
        loopflag = 1
        Do while loopflag = 1
            NewMsk = InputBox("�T�u�l�b�g�}�X�N����͂��Ă��������B" & vbCrLf & "��F255.255.255.0",Title2,"255.255.255.0")
            '##### �L�����Z������
            If IsEmpty(NewMsk ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
            '##### �l�̓��͂Ȃ�
            If Len(NewMsk) = 0 Then
                MsgBox "�l�����͂���Ă��܂���B"
                NewMsk = InputBox("�T�u�l�b�g�}�X�N����͂��Ă��������B" & vbCrLf & "��F255.255.255.0",Title2,"255.255.255.0")
                If IsEmpty(NewMsk) Then
                    MsgBox "�L�����Z�����܂����B"
                    WScript.Quit
                End If
            '##### ��L�ȊO�i����l�j
            Else
                loopflag = 0
                Exit Do
            End If
        Loop
        
        '##### �f�t�H���g�Q�[�g�E�F�C�ݒ�
        loopflag = 1
        Do while loopflag = 1
            NewGWY = InputBox("�f�t�H���g�Q�[�g�E�F�C����͂��Ă��������B" & vbCrLf & "��F10.255.8.254",Title2,"10.255.8.254")
            '##### �L�����Z������
            If IsEmpty(NewGWY ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
            '##### �l�̓��͂Ȃ�
            If Len(NewGWY) = 0 Then
                MsgBox "�l�����͂���Ă��܂���B"
                NewGWY = InputBox("�f�t�H���g�Q�[�g�E�F�C����͂��Ă��������B" & vbCrLf & "��F10.255.8.254",Title2,"10.255.8.254")
                If IsEmpty(NewGWY) Then
                    MsgBox "�L�����Z�����܂����B"
                    WScript.Quit
                End If
            '##### ��L�ȊO�i����l�j
            Else
                loopflag = 0
                Exit Do
            End If
        Loop
        
        '##### DNS�ݒ�1
        DnsSv1 = InputBox("�D��DNS�T�[�o�[����͂��Ă��������B" & vbCrLf & "��F8.8.8.8�i�ݒ�Ȃ��ł�O.K�j",Title4)
            '##### �L�����Z������
            If IsEmpty(DnsSv1 ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
        
        '##### DNS�ݒ�2
        DnsSv2 = InputBox("���DNS�T�[�o�[����͂��Ă��������B" & vbCrLf & "��F8.8.8.8�i�ݒ�Ȃ��ł�O.K�j",Title5)
            '##### �L�����Z������
            If IsEmpty(DnsSv2 ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
        
        '##### �ݒ�ύX
        Set WSHShell = WScript.CreateObject("WScript.Shell")
        WSHShell.Run "cmd.exe /c netsh interface ip set address " & iNameAry(nicSelect) & " static " & NewIP & " " & NewMsk & " " & NewGWY
        WSHShell.Run "cmd.exe /c netsh interface ip set address """ & iNameAry(nicSelect) & """ static " & NewIP & " " & NewMsk & " " & NewGWY
        WSHShell.Run "cmd.exe /c netsh interface ip set dns " & iNameAry(nicSelect) & " static " & DnsSv1 , 0, True
        WSHShell.Run "cmd.exe /c netsh interface ip add dns " & iNameAry(nicSelect) & " addr=" & DnsSv2 ,0, True
        
        '##### IP�A�h���X�\��
        Set d=CreateObject("htmlfile")
        d.parentWindow.setTimeout GetRef("proc"),100
        Sub proc
        Set wShell = CreateObject("WScript.Shell")
        wShell.PopUp "�������ł��B���΂炭���҂����������B",4
        WScript.Timeout=100

        End Sub

        WScript.Sleep 4000
        Set WSHShell = WScript.CreateObject("WScript.Shell")
        Set oExec = WshShell.Exec("netsh interface ipv4 show config")
        WScript.echo oExec.StdOut.ReadAll


    '##### DHCP�L����
    Case    3
        ' ##### InputBox�\��
        If networks.Items.Count > 1 Then
            nicSelect = InputBox("�ݒ肷��l�b�g���[�N�J�[�h�̐�������͂���OK�����I��ł��������B(0�`" & networks.Items.Count-1 & "�̒l)" & vbCrLf & iName,Title,1)
            ' ##### �L�����Z���{�^������
            If IsEmpty(nicSelect ) Then
                MsgBox "�L�����Z�����܂����B"
                WScript.Quit
            End If
            '##### �l�̓��͂Ȃ�
            If Not IsNumeric(nicSelect) Then
                MsgBox "�l�����͂���Ă��܂���B������x���s�������Ă��������B"
                WScript.Quit
                '##### ������l�̓���
                ElseIf CDbl(nicSelect) > (networks.Items.Count-1) Or nicSelect*1000 Mod 1000 <> 0 Or CDbl(nicSelect) < 0 Then
                    MsgBox "�ݒ肵���l�Ɍ�肪����܂��B������x���s�������Ă��������B"
                    WScript.Quit
                Else
             End If
        End If
        Set WSHShell = WScript.CreateObject("WScript.Shell")
        WSHShell.Run "cmd.exe /c netsh interface ip set address """ & iNameAry(nicSelect) &""" dhcp"
        WSHShell.Run "cmd.exe /c netsh interface ip set dns """ & iNameAry(nicSelect) &""" dhcp"
        WSHShell.Run "cmd.exe /c netsh interface ip set address " & iNameAry(nicSelect) & " dhcp"
        WSHShell.Run "cmd.exe /c netsh interface ip set dns " & iNameAry(nicSelect) & " dhcp"
        '##### IP�A�h���X�\��
        Set d=CreateObject("htmlfile")
        d.parentWindow.setTimeout GetRef("proc"),100
        Sub proc
        Set wShell = CreateObject("WScript.Shell")
        wShell.PopUp "�������ł��B���΂炭���҂����������B",4
        WScript.Timeout=100

        End Sub

        WScript.Sleep 4000
        Set WSHShell = WScript.CreateObject("WScript.Shell")
        Set oExec = WshShell.Exec("netsh interface ipv4 show config")
        WScript.echo oExec.StdOut.ReadAll

    '##### ��O����
    Case Else
        WScript.Echo "�ݒ肵���l�Ɍ�肪����܂��B������x���s�������Ă��������B"
        WScript.Quit
End Select
