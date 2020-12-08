/**
 * LF_Nexus - Generates the assets used for LifeFitness custom theme
 * @version 1.0.0
 * @author 7Summits
 *
 * COMPILED FILE DO NOT DIRECTLY EDIT
 */
({

    getFiles: function getFiles(cmp) {
        var _this = this;

        var recordId = cmp.get('v.recordId');
        var maxLength = cmp.get('v.maxLength');

        console.log('maxLength:', maxLength);

        var action = cmp.get('c.getFiles');

        action.setParams({
            recordId: recordId,
            maxLength: maxLength
        });

        action.setStorable();

        action.setCallback(this, function (response) {
            var state = response.getState();

            // check if the request was successful or not
            if (cmp.isValid() && state === 'SUCCESS') {
                var results = response.getReturnValue();

                // format the topics for FE use
                var preparedFiles = _this.helpers.prepareFiles(results);

                cmp.set('v.fileList', preparedFiles);
            } // end success / component valid check
        }); // end callback

        $A.enqueueAction(action);
    },

    showPreview: function showPreview(event) {
        var id = event.currentTarget.dataset.id;

        $A.get('e.lightning:openFiles').fire({
            recordIds: [id]
        });
    },
    setHeight: function setHeight(component) {
        var url = window.location.href;
        var fileList = component.get('v.fileList');
        if (url.indexOf('livepreview') == -1 && fileList.length > 0) {
            var height = document.getElementById('list-wrapper').clientHeight;
            var appEvent = $A.get('e.c:Peak_KnowledgeListEvent');
            appEvent.setParams({
                'eventValue': height
            });
            appEvent.fire();
        }
    },

    /**
     * Helper functions
     */
    helpers: {

        prepareFiles: function prepareFiles() {
            var _this2 = this;

            var files = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];

            var results = JSON.parse(JSON.stringify(files));

            results.forEach(function (file, index) {
                file.lastModifiedDate = $A.localizationService.formatDate(file.lastModifiedDate, 'MMM DD, YYYY');
                file.contentSize = _this2.formatFileSize(file.contentSize);
            });

            return results;
        },

        formatFileSize: function formatFileSize() {
            var size = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 0;

            // map containing b,kb,mb,gb,tb actual bit values
            var map = {
                b: 1,
                kb: 1 << 10,
                mb: 1 << 20,
                gb: 1 << 30,
                tb: (1 << 30) * 1024
            };

            // get absolute value of the size
            var absSize = Math.abs(size);

            // determine which type of data size we have
            var unit = '';
            if (absSize >= map.tb) {
                unit = 'TB';
            } else if (absSize >= map.gb) {
                unit = 'GB';
            } else if (absSize >= map.mb) {
                unit = 'MB';
            } else if (absSize >= map.kb) {
                unit = 'KB';
            } else {
                unit = 'B';
            }

            // convert to unit type
            var convertedSize = size / map[unit.toLowerCase()];

            // remove decimals
            var results = convertedSize.toFixed();

            return results + unit;
        } // end helpers

    } });