public class EnrollmentComponentTypes {
    /**
    *   @ALIKM 20/apr/2020- commenting out changes
        private static EnrollmentComponentTypes instance = null;
        public static Map<String, ComponentKind> typesMap {
            get {return typesMap; }
            set {
                typesMap = new Map<String, ComponentKind>();
                for (ComponentKind enumValue : ComponentKind.values()) {
                    typesMap.put(String.valueOf(enumValue), enumValue);
                }
            }
        }
        
        private EnrollmentComponentTypes() {
        }
    
        public static EnrollmentComponentTypes getInstance() {
        
            if (instance==null) {
                instance = new EnrollmentComponentTypes();
            }
            return instance;
        }
    
        public enum ComponentKind {
            STUDENT,
            PROCESS,
            STAGE,
            MESSAGE,
            FORM,
            FLAG,
            SECTION,
            DOCUMENT,
            QUESTION,
            TEXT,
            QUESTIONGROUP,
            UNKNOWN
        }
    */
}