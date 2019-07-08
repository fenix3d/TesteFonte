#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE  'TBICONN.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE   'RWMAKE.CH'
#INCLUDE    'TOTVS.CH'
#INCLUDE   'COLORS.CH'
#INCLUDE   'FILEIO.CH'
#INCLUDE  'MSMGADD.CH'
#INCLUDE 'TCBROWSE.CH'

#DEFINE CRLF chr( 13 ) + chr( 10 )

//+----------------------+---------------------------------------+------------+
//| Programa  : TLCSN    | Autor : Fábio de Abreu B              | 26/05/2019 |
//+----------------------+---------------------------------------+------------+
//| Descricao : Tela de Consulta de Produtos.                                 |
//+-----------+--------------------------------------------------+------------+

user function TLCSN()

// -----------------------------------------
    local   _aArea    := GetArea()
    local   _aButtons := {}
    local   _aLista   := { 'Descrição' , 'Código' }
    local   _cCombo   := ''
    local   _nTamCamp := 20 
    local   _nOpc     := 0
    local   _lOpc     := .F.
    local   _cItem    :=  Soma1(strzero( 0 , tamsx3( 'C6_ITEM' )[1] ))
    local   _cCampo   := ''
    local   _nPreco   := 0
    local   _cTES     := supergetmv( 'MV_XTES' , .T. , '527' )
    local   _cLin     := '01'
// -----------------------------------------
    private _oSize
    private _oDlg
    private cCadastro := 'Consulta de Produtos'
    private _lSaldo   := .T.
    private _oTGet1
    private _oTGettotvs2
    private _oSayT1
    private _oSayT2
    private _oBtn1
    private _oBtn2
    private _oCombo
    private _oMark
    private _oCheck
    private _cTGet1   := space( tamsx3( 'B1_DESC'    )[1] )
    private _cTGet2   := Iif (!empty(M->C5_TABELA), M->C5_TABELA, space( tamsx3( 'C5_CONDPAG' )[1] ) )
    private _oFnt01   := TFont():New( 'Arial Narrow' , , 20 , , .T. , , , , , .F. , )
    private _oOK      := LoadBitmap( GetResources() , 'WFCHK_MDI'   )
    private _oNO      := LoadBitmap( GetResources() , 'WFUNCHK_MDI' )
    private _cCliente := ''
    private _cLoja    := ''
// -----------------------------------------
    
//---------------------------
//  [ Calcula Dimensões da Tela ]
//---------------------------
    _oSize := FwDefSize():New() 
    _oSize:lLateral  := .F.                               // Calculo vertical
    _oSize:AddObject( 'JANELA1' , 100 , 005 , .T. , .T. ) // Totalmente dimensionavel
    _oSize:AddObject( 'JANELA2' , 100 , 065 , .T. , .T. ) // Totalmente dimensionavel
    _oSize:AddObject( 'JANELA3' , 100 , 030 , .T. , .T. ) // Totalmente dimensionavel

    _oSize:lProp    := .T.                                // Proporcional
    _oSize:aMargins := { 2 , 2 , 2 , 2 }                  // Espaco ao lado dos objetos 0, entre eles 3

    _oSize:Process()                                      // Dispara os calculos

    DEFINE MSDIALOG _oDlg TITLE cCadastro FROM _oSize:aWindSize[1] , _oSize:aWindSize[2] TO ;
                                               _oSize:aWindSize[3] , _oSize:aWindSize[4] OF oMainWnd PIXEL Style DS_MODALFRAME
    MontaTab()

    bOk     := {|| _lOpc := ValidTab( 'Tabela' ) , iif( _lOpc , _nOpc := 1 , _nOpc := 0 ) }
    bCancel := {|| _oDlg:End() }

//  Titulo
    _oSayT1 :=      TSay():New( _oSize:GetDimension( 'JANELA1' , 'LININI' )      , _oSize:GetDimension( 'JANELA1' , 'COLINI' ) , {|| 'Lista de Produtos'   } , _oDlg , , _oFnt01 , , , , .T. , CLR_BLUE , CLR_WHITE , 200 , 010 )
    _oSayT2 :=      TSay():New( _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 50 , _oSize:GetDimension( 'JANELA3' , 'COLINI' ) , {|| 'Pesquisa de Produto' } , _oDlg , , _oFnt01 , , , , .T. , CLR_BLUE , CLR_WHITE , 200 , 010 )

    _oCombo := tComboBox():New( _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 65 , _oSize:GetDimension( 'JANELA3' , 'COLINI' ) , { |u|if( PCount() > 0 , _cCombo:=u , _cCombo ) } , _aLista , 050 , 013 , _oDlg , , , , , , .T. , , , , , , , , , '_cCombo' )

    @ _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 65 , _oSize:aWindSize[2] + 050 MSGET _oTGet1 VAR _cTGet1 Picture '@!' WHEN .T. SIZE 100 , 010 OF _oDlg PIXEL

    _oBtn1  :=   TButton():New( _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 65 , _oSize:aWindSize[2] + 152 , 'Consultar' , _oDlg , { ||FiltroTab( .T. , _cCombo , _cTGet1 , _lSaldo , .F. ) } , 30 , 12 , , , .F. , .T. , .F. , , .F. , , , .F. )
    _oBtn2  :=   TButton():New( _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 65 , _oSize:aWindSize[2] + 185 , 'Carregar'  , _oDlg , { ||FiltroTab( .F. , ''      , ''      , _lSaldo , .F. ) } , 30 , 12 , , , .F. , .T. , .F. , , .F. , , , .F. )

    _oCheck := TCheckBox():Create( _oDlg , {||_lSaldo} , _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 70 , _oSize:aWindSize[2] + 218 , 'Somente Produtos com Estoque' , 100 , 210 , , , , , , , , .T. , , , )
    _oCheck:bChange := {||_lSaldo := !_lSaldo }

    @ _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 57 , _oSize:aWindSize[2] + 308 SAY 'Tab. Preço' SIZE 100 , 012 OF _oDlg PIXEL
    @ _oSize:GetDimension( 'JANELA3' , 'LININI' ) + 65 , _oSize:aWindSize[2] + 308 MSGET _oTGet2 VAR _cTGet2 Picture '@!' WHEN .T. SIZE _nTamCamp , 010 OF _oDlg PIXEL F3 'DA0'

    FiltroTab( .F. , ''      , ''      , _lSaldo , .F. ) 
    ACTIVATE MSDIALOG _oDlg On Init EnchoiceBar( _oDlg , bOk , bCancel , , @_aButtons , /*nRecno*/ , /*cAlias*/ , /*lMashups*/ , /*lImpCad*/ , .F. , .T. , /*lWalkThru*/ , cCadastro ) CENTERED
    
// -----------------------------------------

    if ( _nOpc == 1 )

        if ( empty( M->C5_CLIENTE ) )
            SelecCli()
        endif

        FiltroTab( , '' , '' , '' , .T. )

        M->C5_CLIENTE := SA1->A1_COD
        M->C5_LOJACLI := SA1->A1_LOJA
        M->C5_NATUREZ := SA1->A1_NATUREZ
        M->C5_CLIENT  := SA1->A1_COD
        M->C5_LOJAENT := SA1->A1_LOJA
        M->C5_TIPOCLI := SA1->A1_TIPO
        M->C5_CONDPAG := GetAdvFval( 'DA0' , 'DA0_CONDPG' , xfilial( 'DA0' ) + _cTGet2 , 1 )
        M->C5_TABELA  := _cTGet2

        if ExistTrigger( 'C5_CLIENTE' )
            RunTrigger( 1 , , , , )
        endif

        GetdRefresh()

        SALP->( dbgotop() )

        if ( len( aCols ) > 1 .OR. ;
           !empty( aCols[len( aCols )][GDFieldPos( 'C6_PRODUTO' ) ] ) )

            for _nA := 1 to len( aCols )
                _cItem :=  aCols[_nA][GDFieldPos( 'C6_ITEM' ) ] 
            next _nA

        endif

        do while SALP->( !eof() )

            if ( SALP->SA_OK )
          
                if !empty( aCols[len( acols )][GDFieldPos( 'C6_PRODUTO' )] ) .AND. ; 
                   !empty( aCols[len( acols )][GDFieldPos( 'C6_DESCRI'  )] )         

                 _cItem := Soma1( _cItem )

                    if ( _cItem <> '01' )
                        aadd( aCols , array( len( aHeader ) + 1 ) )
                    endif

                endif    
                                                                      
                for _nAcols := 1 to len( aHeader )

                    _cCampo  := alltrim( aHeader[_nAcols,2] )
                    _nSldQtd := SALP->SA_QUANT
                    _nPreco  := GetAdvFval( 'DA1' , 'DA1_PRCVEN' , xfilial( 'DA1' ) + _cTGet2 + padr( SALP->SA_COD , tamsx3( 'B1_COD' )[1] ) , 1 )

                    do case

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_ITEM'
                            aCols[len( aCols )][_nAcols] := _cItem

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_PRODUTO'
                            aCols[len( aCols )][_nAcols] := padr( SALP->SA_COD , tamsx3( 'B1_COD' )[1] )
                            SB1->( dbsetorder(1) ) // B1_FILIAL + B1_COD
                            SB1->( msseek(     xfilial( 'SB1' ) + padr( SALP->SA_COD , tamsx3( 'B1_COD' )[1] ) ) )

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_DESCRI'
//                          aCols[len( aCols )][_nAcols] := SB1->B1_DESC
                            aCols[len( aCols )][_nAcols] := GetAdvFval( 'SB5' , 'B5_CEME' , xfilial( 'SB5' ) + padr( SALP->SA_COD , tamsx3( 'B1_COD' )[1] ) , 1 , 0 )

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_SEGUM'
                            aCols[len( aCols )][_nAcols] := SB1->B1_SEGUM

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_UM'
                            aCols[len( aCols )][_nAcols] := SB1->B1_UM

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_QTDVEN'
                            aCols[len( aCols )][_nAcols] := a410Arred( _nSldQtd , 'C6_QTDVEN' )

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_QTDLIB'
                            aCols[len( aCols )][_nAcols] := a410Arred( _nSldQtd , 'C6_QTDLIB' )

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_PRCVEN'
                            aCols[len( aCols )][_nAcols] := _nPreco

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_PRUNIT'
                            aCols[len( aCols )][_nAcols] := _nPreco

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_VALOR'
                            aCols[len( aCols )][_nAcols] := _nPreco * _nSldQtd

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_VALDESC'
                            aCols[len( aCols )][_nAcols] := 0

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_DESCONT'
                            aCols[len( aCols )][_nAcols] := 0

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_LOCAL'
                            aCols[len( aCols )][_nAcols] := SB1->B1_LOCPAD

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_TES'
                            cCodTES := _cTES
                            aCols[len(aCols)][_nAcols] := cCodTES
                            SF4->( dbsetorder(1) ) // F4_FILIAL + F4_CODIGO
                            SF4->( msseek(     xfilial( 'SF4' ) + cCodTES ) )

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_CC'
                            aCols[len( aCols )][_nAcols] := SB1->B1_CC

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_CONTA'
                            aCols[len( aCols )][_nAcols] := SB1->B1_CONTA

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_CF'
                            aCols[len( aCols )][_nAcols] := SF4->F4_CF

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_ALI_WT'
                            aCols[len( aCols )][_nAcols] := 'SC6'

                        case alltrim( aHeader[_nAcols][2] ) == 'C6_REC_WT'
                            aCols[len( aCols )][_nAcols] := 0

                        otherwise
                            aCols[len( aCols )][_nAcols] := criavar( _cCampo )
                    endcase

                next _nAcols

                aCols[len( aCols )][len( aHeader ) + 1 ] := .F.
            
            endif

            GetdRefresh()                   
            SetFocus( oGetDad:oBrowse:hWnd ) 
            oGetDad:Refresh()               
            A410LinOk( oGetDad )             

            SALP->( dbskip() )

        enddo

    endif

    restarea( _aArea )

return()

//+----------------------+---------------------------------------+------------+
//| Funcao    : MontaTab | Autor : Fábio de Abreu B              | 30/05/2019 |
//+----------------------+---------------------------------------+------------+
//| Descricao : Função para montagem da tabela temporária.                    |
//+-----------+--------------------------------------------------+------------+

static function montatab( _lFlag , _cCombo , _cBox , _lSaldo )

// -----------------------------------------
    local   _aArea1    :=        getarea()
    local   _aSx3      := SX3->( getarea() )
    local   _aStruct   := {}
    local   _cAlias1   := 'SALP'
    local   _aColuna   := {}
    local   _cArqTemp
    local   _cQueryA   := ''
    local   _cAliasA   := getnextalias()
    local   _cQueryB   := ''
    local   _cAliasB   := getnextalias()
    local   _aTabela   := {}
    local   _nA        := 0
    local   _cGrpGeVen := supergetmv( 'MV_XGERVEN' , .T. , '000005' )
    local   _cTabPrc   := supergetmv( 'MV_XTABPRC' , .T. , '006'    )
    local   _cArmazem  := supergetmv( 'MV_XARMAZ'  , .T. , 'RV'     )
    local   _cCodUser  := retcodusr()
    local   _cNomeUser := usrretname( _cCodUser )
    local   _aCodGrupo := usrretgrp( _cNomeUser , _cCodUser )
    local   _lRet      := .F.
    local   _nReserva  := 0
    local   _nSalPed   := 0
    local   _nQatu     := 0
// -----------------------------------------
    private _aBrowse   := {}
// -----------------------------------------

    for _nT := 1 to len( _aCodGrupo )
        if ( _aCodGrupo[_nT] $ _cGrpGeVen )
            _lRet := .T.
            exit
        endif
    next _nT

    _cTabPrc  := "'" + strtran( alltrim( _cTabPrc  ) , "|" , "','" ) + "'"
    _cArmazem := "'" + strtran( allTrim( _cArmazem ) , "|" , "','" ) + "'"

// -----------------------------------------
    _cQueryB     := " SELECT DA0_CODTAB , "
    _cQueryB     += "        DA0_DESCRI , "
    _cQueryB     += "        DA0_DATDE  , "  //
    _cQueryB     += "        DA0_DATATE   "  //
    _cQueryB     += "   FROM "                   + retsqlname( 'DA0' ) + " DA0"
    _cQueryB     += "  WHERE DA0_FILIAL     = '" +    xfilial( 'DA0' ) + "' "
    _cQueryB     += "    AND DA0.D_E_L_E_T_ = ' ' "
    if( !_lRet )
        _cQueryB += "    AND DA0_CODTAB NOT IN (" + _cTabPrc           + ") "
    endif
// -----------------------------------------
    _cQueryB := ChangeQuery( _cQueryB )
    if( select( _cAliasB ) > 0 )
        dbselectarea( _cAliasB )
        (_cAliasB)->( dbclosearea() )
    endif
    dbUseArea( .T. , "TOPCONN" , TcGenQry( , , _cQueryB ) , _cAliasB , .T. , .T. )
// -----------------------------------------

    dbselectarea( _cAliasB )

    if ( (_cAliasB)->( !eof() ) )

        do while (_cAliasB)->( !eof() )
        
            if stod( (_cAliasB)->DA0_DATDE  ) <= ddatabase .AND. ;
             ( stod( (_cAliasB)->DA0_DATATE ) >= ddatabase .OR. empty( (_cAliasB)->DA0_DATATE ) )

                aadd( _aTabela , { (_cAliasB)->DA0_CODTAB , (_cAliasB)->DA0_DESCRI } )
                
            endif
            
            (_cAliasB)->( dbskip() )

        enddo

    endif
    
    if len( _aTabela ) == 0
        alert( 'Nenhuma tabela vigente!' )
        return
    endif

// ----------------------------------------------

    aadd( _aBrowse , { 'SA_OK' , ''  , '' , '' } )
    aadd( _aStruct , { 'SA_OK' , 'L' , 01 , 0  } )

// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'SB1' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'SB1'
            if ( alltrim( SX3->X3_CAMPO ) == 'B1_FILIAL' )
//              aadd( _aStruct , { 'SA_FILIAL' , SX3->X3_TIPO   , SX3->X3_TAMANHO       , SX3->X3_DECIMAL } )
//              aadd( _aColuna , { 'SA_FILIAL' , SX3->X3_TITULO , SX3->X3_TIPO          , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
//              aadd( _aBrowse , { 'SA_FILIAL' , ''             , alltrim( X3Titulo() ) , SX3->X3_PICTURE } )
            elseif ( alltrim( SX3->X3_CAMPO ) == 'B1_COD' )
                aadd( _aStruct , { 'SA_COD' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                 , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_COD' , SX3->X3_TITULO , SX3->X3_TIPO                                    , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_COD' , ''             , alltrim( X3Titulo()) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
//          elseif ( alltrim( SX3->X3_CAMPO ) == 'B1_DESC' )
//              aadd( _aStruct , { 'SA_DESC' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                 , SX3->X3_DECIMAL } )
//              aadd( _aColuna , { 'SA_DESC' , SX3->X3_TITULO , SX3->X3_TIPO                                    , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
//              aadd( _aBrowse , { 'SA_DESC' , ''             , alltrim( X3Titulo()) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
//          elseif ( alltrim( SX3->X3_CAMPO ) == 'B1_GRUPO' )
//             aadd( _aStruct , { 'SA_GRUPO' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                 , SX3->X3_DECIMAL } )
//             aadd( _aColuna , { 'SA_GRUPO' , SX3->X3_TITULO , SX3->X3_TIPO                                    , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
//             aadd( _aBrowse , { 'SA_GRUPO' , ''             , alltrim( X3Titulo()) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'SB5' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'SB5'
            if ( alltrim( SX3->X3_CAMPO ) == 'B5_CEME' )
                aadd( _aStruct , { 'SA_DESC' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                  , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_DESC' , SX3->X3_TITULO , SX3->X3_TIPO                                     , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_DESC' , ''             , alltrim( X3Titulo() ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'SBM' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'SBM'
            if ( alltrim( SX3->X3_CAMPO ) == 'BM_DESC' )
                aadd( _aStruct , { 'SA_GRUPO' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                  , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_GRUPO' , SX3->X3_TITULO , SX3->X3_TIPO                                     , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_GRUPO' , ''             , alltrim( X3Titulo() ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'DA1' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'DA1'
            if( alltrim( SX3->X3_CAMPO ) == 'DA1_PRCVEN' )
                for _nA := 1 to len( _aTabela )
                    aadd( _aStruct , { 'SA_PRCVE' + strzero( _nA , 2 ) , SX3->X3_TIPO  , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                    aadd( _aColuna , { 'SA_PRCVE' + strzero( _nA , 2 ) , _aTabela[_nA] , SX3->X3_TIPO    , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                    aadd( _aBrowse , { 'SA_PRCVE' + strzero( _nA , 2 ) , ''            , 'Tab Prc: ' + alltrim( _aTabela[_nA][1] ) + ;
                                                                                                 '-' + alltrim( _aTabela[_nA][2] ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
                next _nA
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'SB2' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'SB2'
            if ( alltrim( SX3->X3_CAMPO ) == 'B2_QATU' )
                aadd( _aStruct , { 'SA_SALDO' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                  , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_SALDO' , SX3->X3_TITULO , SX3->X3_TIPO                                     , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_SALDO' , ''             , alltrim( X3Titulo() ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            elseif( alltrim( SX3->X3_CAMPO ) == 'B2_SALPEDI' )
                aadd( _aStruct , { 'SA_SALPEDI' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                  , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_SALPEDI' , SX3->X3_TITULO , SX3->X3_TIPO                                     , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_SALPEDI' , ''             , alltrim( X3Titulo() ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------
    dbselectarea( 'SX3' )
    dbsetorder( 1 ) // X3_ARQUIVO + X3_ORDEM
    if ( dbseek( 'SC6' ) )
        do while !SX3->( eof() ) .AND. SX3->X3_ARQUIVO == 'SC6'
            if ( alltrim( SX3->X3_CAMPO ) == 'C6_QTDVEN' )
                aadd( _aStruct , { 'SA_QUANT' , SX3->X3_TIPO   , SX3->X3_TAMANHO                                  , SX3->X3_DECIMAL } )
                aadd( _aColuna , { 'SA_QUANT' , SX3->X3_TITULO , SX3->X3_TIPO                                     , SX3->X3_PICTURE , 1 , SX3->X3_TAMANHO , SX3->X3_DECIMAL } )
                aadd( _aBrowse , { 'SA_QUANT' , ''             , alltrim( X3Titulo() ) + space( SX3->X3_TAMANHO ) , SX3->X3_PICTURE } )
            endif
            SX3->( dbskip() )
        enddo
    endif
// ----------------------------------------------

    _cArqTemp  := CriaTrab( _aStruct , .T. )

    if select(_cAlias1) > 0
        dbselectarea( _cAlias1 )
        dbclosearea()
    endif

      dbUseArea( .T. , __LocalDriver , _cArqTemp , _cAlias1 , .F. , .F. )
      dbCreateIndex( _cArqTemp + OrdBagExt() , 'SA_GRUPO+SA_DESC+SA_COD' , {||'SA_GRUPO+SA_DESC+SA_DOC' } )

// ----------------------------------------------

    _cQueryA := " SELECT B1_COD     , "
    _cQueryA += "        B1_DESC    , "
    _cQueryA += "        B1_GRUPO   , "
    _cQueryA += "        DA1_CODPRO , "
    _cQueryA += "        B2_QATU    , "
    _cQueryA += "        B2_RESERVA , "
    _cQueryA += "        B2_SALPEDI , "
    _cQueryA += "        B5_CEME    , "

    for _nA := 1 to len( _aTabela )
        if ( _nA < len( _aTabela ) )
            _cQueryA += "[" + alltrim( _aTabela[_nA][1] ) + "] AS TABELA" + strzero( _nA , 2 ) + "," + CRLF
        else
            _cQueryA += "[" + alltrim( _aTabela[_nA][1] ) + "] AS TABELA" + strzero( _nA , 2 ) + CRLF
        endif
    next _nA

    _cQueryA += "   FROM ( SELECT DA1_CODTAB AS TABELA  , "
    _cQueryA += "                 B1_COD                , "
    _cQueryA += "                 B1_DESC               , "
    _cQueryA += "                 B1_GRUPO              , "
    _cQueryA += "                 DA1_CODPRO            , "
    _cQueryA += "                 B2_QATU               , "
    _cQueryA += "                 B2_RESERVA            , "
    _cQueryA += "                 B2_SALPEDI            , "
    _cQueryA += "             SUM(DA1_PRCVEN) AS QTDTAB , "
    _cQueryA += "                 B5_CEME                 "
    _cQueryA += "            FROM " + retsqlname( 'SB1' ) + " SB1 "
    _cQueryA += "      INNER JOIN " + retsqlname( 'DA1' ) + " DA1 "
    _cQueryA += "              ON B1_COD = DA1_CODPRO "
    _cQueryA += "      INNER JOIN " + retsqlname( 'SB2' ) + " SB2 "
    _cQueryA += "              ON B1_COD = B2_COD     "
    _cQueryA += "      INNER JOIN " + retsqlname( 'SB5' ) + " SB5 "
    _cQueryA += "              ON B5_COD = B1_COD     "
    _cQueryA += "           WHERE B2_FILIAL       = '" + xfilial( 'SB2' ) + "' "
    _cQueryA += "             AND B2_LOCAL       IN (" + _cArmazem        + ") "
    if ( !_lRet )
        _cQueryA += "         AND DA1_CODTAB NOT IN (" + _cTabPrc         + ") "
    endif
    _cQueryA += "             AND SB1.D_E_L_E_T_ = ' ' "
    _cQueryA += "             AND B1_MSBLQL <>  '1' "
    _cQueryA += "             AND SB2.D_E_L_E_T_ = ' ' "
    _cQueryA += "             AND DA1.D_E_L_E_T_ = ' ' "
    _cQueryA += "             AND SB5.D_E_L_E_T_ = ' ' "
    _cQueryA += "        GROUP BY DA1_CODTAB , "
    _cQueryA += "                 B1_COD     , "
    _cQueryA += "                 B1_DESC    , "
    _cQueryA += "                 B1_GRUPO   , "
    _cQueryA += "                 DA1_CODPRO , "
    _cQueryA += "                 B2_QATU    , "
    _cQueryA += "                 B2_RESERVA , "
    _cQueryA += "                 B2_SALPEDI , "
    _cQueryA += "                 B5_CEME      ) LINHAS "
    _cQueryA += " PIVOT (SUM(QTDTAB) FOR TABELA IN ("
    for _nA := 1 to len( _aTabela )
        if ( _nA < len( _aTabela ) )
            _cQueryA += "[" + alltrim( _aTabela[_nA][1] ) + "]" + ","
        else
            _cQueryA += "[" + alltrim( _aTabela[_nA][1] ) + "]"
        endif
    next _nA
    _cQueryA += " )) COLUNAS"
    _cQueryA += " ORDER BY 3 , 8"
    _cQueryA := ChangeQuery( _cQueryA )

    MemoWrite( 'C:\Temp\TLCSN.txt' , _cQueryA )

    if ( select( _cAliasA ) > 0 )
        dbselectarea( _cAliasA )
        (_cAliasA)->( dbclosearea() )
    endif

    dbUseArea( .T. , 'TOPCONN' , TcGenQry( , , _cQueryA ) , _cAliasA , .T. , .T. )

    dbselectarea( _cAliasA )
  
    if ( (_cAliasA)->( !eof() ) )

        do while (_cAliasA)->( !eof() )

            dbselectarea( _cAlias1 )
            reclock( _cAlias1 , .T. )
                SALP->SA_OK      := .F.
                SALP->SA_COD     := (_cAliasA)->B1_COD
                SALP->SA_DESC    := (_cAliasA)->B5_CEME
                for _nA := 1 to len( _aTabela )
                    SALP->&( 'SA_PRCVE' + strzero( _nA , 2 ) ) := (_cAliasA)->&( 'TABELA' + strzero( _nA , 2 ) )
                next _nA
                SALP->SA_SALDO   := (_cAliasA)->B2_QATU-(_cAliasA)->B2_RESERVA //(_cAliasA)->B2_SALDO
                SALP->SA_SALPEDI := (_cAliasA)->B2_SALPEDI
            msunlock()

            (_cAliasA)->( dbskip() )

        enddo

    endif
    IndRegua('SALP',_cArqTemp,'SA_GRUPO',,,'Montando Tela')  
    MontBrowse( _aColuna , _aBrowse , _aTabela )

    (_cAliasA)->( dbclosearea() )

    restarea( _aSx3   )
    restarea( _aArea1 )

return()

//+-----------------------+--------------------------------------+------------+
//| Funcao    : FiltroTab | Autor : Fábio de Abreu B             | 02/06/2019 |
//+-----------------------+--------------------------------------+------------+
//| Descricao : Função para montagem da tabela temporária.                    |
//+-----------+--------------------------------------------------+------------+

static function FiltroTab( _lFlag , _cCombo , _cBox , _lSaldo , _lConfirma )

// -----------------------------------------
    local _aArea3    := getarea()
    local _cConteudo := ''
    local _cContent  := ''
// -----------------------------------------

    dbselectarea( 'SALP' )
    SALP->( dbgotop() )

    if ( _lConfirma )
        _cConteudo := 'SA_OK == .T.'
        SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
    else

        if ( _lFlag )

            if ( alltrim( _cCombo ) == 'Código' )

              _cConteudo := "('" + strtran( strtran( alltrim( _cBox ) , ";" , "') $ SA_COD .OR. ('" ) + "') $ SA_COD ",":","') $ SA_COD .AND. ('" )              
              _cContent := alltrim( _cBox )
              
                do while ( at( '  ' , _cContent ) > 0 )
                    _cContent := strtran( _cContent , '  ' , ' ' )
                enddo
                _cContent := '("' + strtran( _cContent , ' ' , ' ' )

                if ( _lSaldo )
                    _cConteudo += ".AND. SA_SALDO > 0"
                    _cConteudo := alltrim( _cConteudo )
                    SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
                else
                    _cConteudo := alltrim( _cConteudo )
                    SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
                endif

            elseif ( alltrim( _cCombo ) == 'Descrição' )

                _cConteudo := "('" + strtran( strtran( alltrim( _cBox ) , ";" , "') $ SA_DESC .OR. ('" ) + "') $ SA_DESC ",":","') $ SA_DESC .AND. ('" )

                if ( _lSaldo )
                    _cConteudo += ".AND. SA_SALDO > 0"
                    _cConteudo := alltrim( _cConteudo )
                    SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
                else
                    _cConteudo := alltrim( _cConteudo )
                    SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
                endif

            endif

        else

            if ( _lSaldo )
                _cConteudo := "SA_SALDO > 0"
                _cConteudo := alltrim( _cConteudo )
                SALP->( dbsetfilter( { || &( _cConteudo ) } , _cConteudo ) )
            else
                dbclearfilter()
            endif

        endif

    endif

    SALP->( dbgobottom() )
    SALP->( dbgotop()    )

    restarea( _aArea3 )

return()

//+------------------------+-------------------------------------+------------+
//| Funcao    : MontBrowse | Autor : Fábio de Abreu B            | 04/06/2019 |
//+------------------------+-------------------------------------+------------+
//| Descricao : Função para montagem do Browse.                               |
//+-----------+--------------------------------------------------+------------+

static function MontBrowse( _aColuna , _aBrowse , _aTabela )

// -----------------------------------------
    local   _nCol     := 3
    local   _aCampo   := {}
    local   _cCampo   := ''
    local   _cBloco   := ''
// -----------------------------------------
    private _cMarca   := getmark()
    private _lInverte := .F.
    private _nMarked  := 0
// -----------------------------------------

    dbselectarea( 'SALP' )
    dbgotop()

    _oMark := TCBrowse():New( _oSize:GetDimension( 'JANELA2' , 'LININI' )     , ;
                              _oSize:GetDimension( 'JANELA2' , 'COLINI' ) - 2 , ;
                              _oSize:GetDimension( 'JANELA2' , 'COLEND' )     , ;
                              _oSize:GetDimension( 'JANELA2' , 'LINEND' )     , /*bLine*/ , , , _oDlg , , , , , {||} , {||} , , , , , , .F. , 'SALP' , .T. , , .F. , , , )

    _oMark:AddColumn( TCColumn():New( ''                                                                , { || iif( SALP->SA_OK , _oOK , _oNO ) } ,                         , , ,        , 002                      , .T. , .F. , , , ,     , ) )
    _oMark:AddColumn( TCColumn():New( rettitle( 'B1_COD'    ) + space( tamsx3( 'B1_COD'    )[1]       ) , { || SALP->SA_COD                     } ,                         , , , 'LEFT' , tamsx3( 'B1_COD'    )[1] , .F. , .T. , , , , .F. , ) )                        , , , 'LEFT' , tamsx3( 'B1_DESC'   )[1] , .F. , .T. , , , , .F. , ) )
    _oMark:AddColumn( TCColumn():New( rettitle( 'B1_DESC'   ) + space( tamsx3( 'B5_CEME'   )[1]       ) , { || SALP->SA_DESC                    } ,                         , , , 'LEFT' , tamsx3( 'B5_CEME'   )[1] , .F. , .T. , , , , .F. , ) )
    _oMark:AddColumn( TCColumn():New( rettitle( 'B2_QATU'     + space( tamsx3( 'B2_QATU'   )[1] + 5 ) ) , { || SALP->SA_SALDO                   } , '@E 999,999,999,999.99' , , , 'LEFT' , tamsx3( 'B2_QATU'   )[1] , .F. , .T. , , , , .F. , ) )
    _oMark:AddColumn( TCColumn():New( rettitle( 'C6_QTDVEN' ) + space( tamsx3( 'C6_QTDVEN' )[1]       ) , { || SALP->SA_QUANT                   } , '@E 999,999,999,999.99' , , , 'LEFT' , tamsx3( 'C6_QTDVEN' )[1] , .F. , .T. , , , , .F. , ) )

    for _nD := 1 to len( _aTabela )
        aadd( _aCampo , 'SALP->SA_PRCVE' + strzero( _nD , 2 ) )
    next _nD

    for _nD := 1 to len( _aTabela )
        _cCampo := _aCampo[_nD]
        _cBloco := "_oMark:AddColumn( TCColumn():New(_aTabela[_nD][2],{ || " + _cCampo + " },'@E 999,999,999,999.99',,,'LEFT',TAMSX3('DA1_PRCVEN')[1],.F.,.T.,,,,.F.,) )"
        &_cBloco
    next _nD

    _oMark:AddColumn( TCColumn():New( rettitle( 'B2_SALPEDI' + space( tamsx3( 'B2_SALPEDI' )[1] ) ) , { || SALP->SA_SALPEDI  } , '@E 999,999,999,999.99' , , , 'LEFT' , tamsx3( 'B2_SALPEDI' )[1] , .F. , .T. , , , , .F. , ) )
    _oMark:lAdjustColSize := .T.
    _oMark:bLDblClick     := {|| DuploClick() }

return( NIL )

//+------------------------+-------------------------------------+------------+
//| Funcao    : DuploClick | Autor : Fábio de Abreu B            | 05/06/2019 |
//+------------------------+-------------------------------------+------------+
//| Descricao : Função que incrementa ou decrementa a variável _nMarked,      |
//|             a ser usada na validação da MsSelect (somente 1 marcado).     |
//+-----------+--------------------------------------------------+------------+

static function DuploClick()

// -----------------------------------------
    local _nPos      := _oMark:COLPOS
    local _oDlg1
    local _cQuant    := space( tamsx3( 'C6_QTDVEN'  )[1] )
    local _nOpc      := 0
    local _cDescri   := 'Quantidade'
    local _cMascara  := X3Picture( 'C6_QTDVEN'  )
// -----------------------------------------

    if ( _nPos == 1 )
        if ( SALP->SA_OK )
            reclock( 'SALP' , .F. )
                SALP->SA_OK := .F.
            msunlock()
        else
            reclock( 'SALP' , .F. )
                SALP->SA_OK := .T.
            msunlock()
        endif
    elseif ( _nPos == 5 )

        DEFINE MSDIALOG _oDlg1 TITLE _cDescri FROM 0 , 0 TO 100 , 165 PIXEL STYLE DS_MODALFRAME

        @ 009 , 009 SAY   'Quantidade'         OF _oDlg1 PIXEL
        @ 020 , 009 MSGET _cQuant SIZE 60 , 10 OF _oDlg1 PIXEL PICTURE _cMascara WHEN .T.

        @ 035 , 009 BUTTON '&Ok'       SIZE 30 , 12 PIXEL ACTION( _nOpc := 1 , _oDlg1:End() ) OF _oDlg1 PIXEL
        @ 035 , 045 BUTTON '&Cancelar' SIZE 30 , 12 PIXEL ACTION(              _oDlg1:End() ) OF _oDlg1 PIXEL

        ACTIVATE MSDIALOG _oDlg1 CENTER

        if ( _nOpc == 1 )

            reclock( 'SALP' , .F. )
                SALP->SA_QUANT := val( _cQuant )
                SALP->SA_OK    := .T.
            msunlock()
    
        endif

    endif

return()

//+------------------------+-------------------------------------+------------+
//| Funcao    : SelecCli   | Autor : Fábio de Abreu B            | 08/06/2019 |
//+------------------------+-------------------------------------+------------+
//| Descricao : Função para selecionar o cliente                              |
//+-----------+--------------------------------------------------+------------+

static function SelecCli()

// -----------------------------------------
    local   _nOpc     := 0
    local   _cDescri  := 'Seleção de Cliente'
    local   _nTamCli  := tamsx3( 'A1_COD'  )[1]
    local   _nTamLoja := tamsx3( 'A1_LOJA' )[1]
    local   _lOpc     := .F.
// -----------------------------------------
    private _oDlg2
    private _cCodCli  := space( _nTamCli  )
    private _cLojaCli := space( _nTamLoja )
// -----------------------------------------

    DEFINE MSDIALOG _oDlg2 TITLE _cDescri FROM 0 , 0 TO 100 , 160 PIXEL STYLE DS_MODALFRAME

    @ 011 , 010 SAY   'Cliente'                     OF _oDlg2 PIXEL
    @ 020 , 010 MSGET _cCodCli  SIZE _nTamCli  , 10 OF _oDlg2 PIXEL F3 'SA1' PICTURE '@!' WHEN .T.

    @ 011 , 045 SAY   'Loja'                        OF _oDlg2 PIXEL
    @ 020 , 045 MSGET _cLojaCli SIZE _nTamLoja , 10 OF _oDlg2 PIXEL          PICTURE "@!" WHEN .F.

    @ 035 , 009 BUTTON '&Ok'       SIZE 30 , 12 PIXEL ACTION( _lOpc := ValidTab( 'Cliente' ) , iif( _lOpc , _nOpc := 1 , _nOpc := 0 ) ) OF _oDlg2 PIXEL
    @ 035 , 045 BUTTON '&Cancelar' SIZE 30 , 12 PIXEL ACTION( _oDlg2:End()                                                            ) OF _oDlg2 PIXEL

    ACTIVATE MSDIALOG _oDlg2 CENTER

    if ( _nOpc == 1 )
        _cCliente := _cCodCli
        _cLoja    := _cLojaCli
    endif

return()

//+------------------------+-----------------------------------------+------------+
//| Funcao    : AltPreco   | Autor : Leandro Ribeiro                 | 10/06/2019 |
//+------------------------+-----------------------------------------+------------+
//| Descricao : Função para verificar se houve alteração em alguma tabela de preço|
//+-----------+------------------------------------------------------+------------+

static function AltPreco( _cTab )

// -----------------------------------------
    local _aArea4  := getarea()
    local _cCodPro := ''
    local _nA      := 0
    local _nPreco  := 0
    local _cCodPrd := ''
    local _nSldQtd := 0
// -----------------------------------------

    for _nA := 1 to len( aCols )

        _cCodPrd := aCols[_nA][GDFieldPos( 'C6_PRODUTO' )]
        _nPreco  := GetAdvFval( 'DA1' , 'DA1_PRCVEN' , xfilial( 'DA1' ) + _cTab + padr( _cCodPrd , tamsx3( 'B1_COD' )[1] ) , 1 )
        _nSldQtd := aCols[_nA][GDFieldPos( 'C6_QTDVEN'  )]

        aCols[_nA][GDFieldPos( 'C6_PRCVEN' )] := _nPreco
        aCols[_nA][GDFieldPos( 'C6_PRUNIT' )] := _nPreco
        aCols[_nA][GDFieldPos( 'C6_VALOR'  )] := _nPreco * _nSldQtd

    next _nA

    restarea( _aArea4 )

return()

//+------------------------+-------------------------------------+------------+
//| Funcao    : ValidTab   | Autor : Fábio de Abreu B            | 11/06/2019 |
//+------------------------+-------------------------------------+------------+
//| Descricao : Função para verificar validade de tabelas de preço            |
//+-----------+--------------------------------------------------+------------+

static function ValidTab( _cBox )

// -----------------------------------------
    local _lRet := .T.
// -----------------------------------------

    if ( _cBox == 'Tabela' )

        if ( empty( _cTGet2 ) )
            MsgInfo( 'Campo Tab. Preço o preenchimento é obrigatório' , 'Validação' )
            _lRet := .F.
        else
            _oDlg:End()
        endif

    elseif ( _cBox == 'Cliente' )

        if ( empty( _cCodCli ) )
            MsgInfo( 'Campo Cliente o preenchimento é obrigatório' , 'Validação' )
            _lRet := .F.
        else
            _oDlg2:End()
        endif

    endif

return( _lRet )

// -----------------------------------------------------------------------
// [ fim de TLCSN.prw ]
// -----------------------------------------------------------------------
