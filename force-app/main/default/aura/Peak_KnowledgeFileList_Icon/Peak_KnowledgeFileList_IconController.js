/**
 * Created by 7Summits on 10/24/17.
 */
({

    doInit: function(cmp, event, helper){
        var type = cmp.get('v.type');

        switch(type){

            case 'jpg':
            case 'png':
            case 'gif':
                cmp.set('v.iconName', 'doctype:image');
                break;

            case 'xlsx':
            case 'xlsm':
            case 'xltx':
            case 'xltm':
            case 'xls':
                cmp.set('v.iconName', 'doctype:excel');
                break;

            case 'pdf':
                cmp.set('v.iconName', 'doctype:pdf');
                break;

            case 'pptx':
            case 'pptm':
            case 'potx':
            case 'potm':
            case 'ppam':
            case 'ppsx':
            case 'ppsm':
            case 'sldx':
            case 'sldm':
            case 'ppt':
                cmp.set('v.iconName', 'doctype:ppt');
                break;

            case 'txt':
                cmp.set('v.iconName', 'doctype:txt');
                break;

            case 'docx':
            case 'docm':
            case 'dotx':
            case 'dotm':
            case 'doc':
                cmp.set('v.iconName', 'doctype:word');
                break;

            case 'zip':
                cmp.set('v.iconName', 'doctype:zip');
                break;

            case 'pages':
                cmp.set('v.iconName', 'doctype:pages');
                break;

            case 'key':
            case 'keynote':
                cmp.set('v.iconName', 'doctype:keynote');
                break;

            default:
                cmp.set('v.iconName', 'doctype:unknown');
        }
    }

})