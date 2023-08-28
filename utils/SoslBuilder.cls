/**
 * @description Abstraction to help generate SOSL queries easier
 *
 * @group services
 * @since 2022
 */

public with sharing class SoslBuilder {
    private String searchTerm;
    private Set<String> searchFields;
    private List<TargetObject> targetObjects;
    static final String NAMESPACE = PIM.getStaticNamespace();

    public SoslBuilder() {
        this.searchTerm = '';
        this.searchFields = new Set<String>();
        this.targetObjects = new List<TargetObject>();
    }

    public class TargetObject {
        private final String bracketL = '(';
        private final String bracketR = ')';
        private String objectType;
        private List<String> fields;
        private String condition;
        private final List<String> defaultReturnFields = new List<String>{'Id', 'Name'};

        public TargetObject(String objectType) {
            if (!objectType.startsWith(SoslBuilder.NAMESPACE)) {
                objectType = SoslBuilder.NAMESPACE + objectType;
            }
            this.objectType = objectType;
            this.fields = defaultReturnFields;
        }

        public TargetObject(SObjectType objectType) {
            this.objectType = objectType.getDescribe().getName();
            this.fields = defaultReturnFields;
        }

        public TargetObject(SObjectType objectType, List<String> fields) {
            this.objectType = objectType.getDescribe().getName();
            this.fields = (fields == null || fields.size() == 0)
                ? defaultReturnFields
                : fields;
        }

        public TargetObject(SObjectType objectType, List<String> fields, String condition) {
            this.objectType = objectType.getDescribe().getName();
            this.fields = (fields == null || fields.size() == 0)
                ? defaultReturnFields
                : fields;
            this.condition = condition;
        }

        public String formatForSearch() {
            String formatted = objectType + bracketL + String.join(fields, ',');
            if (condition != null) {
                formatted += ' WHERE ' + condition;
            }
            return formatted + bracketR;
        }
    }

    public SoslBuilder addSearchTerm(String searchTerm) {
        this.searchTerm = String.escapeSingleQuotes(searchTerm);
        return this;
    }

    public SoslBuilder addSearchField(String fieldName) {
        if (fieldName.contains(',')) {
            return this.addSearchFields(fieldName);
        }
        this.searchFields.add(fieldName.trim());
        return this;
    }

    public SoslBuilder addSearchFields(String fieldNames) {
        return this.addSearchFields(fieldNames.trim().split(','));
    }

    public SoslBuilder addSearchFields(List<String> fieldNames) {
        for (String fieldName : fieldNames) {
            this.searchFields.add(fieldName.trim());
        }
        return this;
    }

    public SoslBuilder addTargetObject(TargetObject to) {
        this.targetObjects.add(to);
        return this;
    }

    public SoslBuilder addTargetObject(String type) {
        this.targetObjects.add(new TargetObject(type));
        return this;
    }

    public SoslBuilder addTargetObject(SObjectType type) {
        this.targetObjects.add(new TargetObject(type));
        return this;
    }

    public SoslBuilder addTargetObjects(List<TargetObject> tos) {
        this.targetObjects.addAll(tos);
        return this;
    }

    public SoslBuilder addTargetObjects(List<String> types) {
        for (String type : types) {
            addTargetObject(type);
        }
        return this;
    }

    public SoslBuilder addTargetObjects(List<SObjectType> types) {
        for (SObjectType type : types) {
            addTargetObject(type);
        }
        return this;
    }

    public override String toString() {
        final String newLine = ' \n';
        String result = 'FIND {' + escapeSosl(this.searchTerm) + '}' + newLine;

        String searchFields = 'IN ';
        if (this.searchFields.isEmpty()) {
            searchFields += 'ALL';
        } else {
            searchFields += String.join(new List<String>(this.searchFields), '\n\t, ');
        }
        result += searchFields + ' FIELDS\n';

        if (this.targetObjects.size() > 0) {
            result += 'RETURNING ';
            for (TargetObject to : this.targetObjects) {
                result += to.formatForSearch() + ',';
            }
            result = result.removeEnd(',');
        }

        return result.trim().normalizeSpace();
    }

    public List<List<SObject>> execute() {
        PIM.debug('SOSL to execute: ' + this.toString());
        return Search.query(this.toString());
    }

    public List<SObject> consolidate() {
        List<SObject> consolidated = new List<SObject>();
        for (List<SObject> resultList : execute()) {
            consolidated.addAll(resultList);
        }
        return consolidated;
    }

    private String escapeSosl(String text) {
        // handle single quotes
        // MVP-18995: remove ' since FIND ignore it
        String escapedText = String.escapeSingleQuotes(text);
        escapedText = escapedText.remove('\\').remove('\'');

        // match special characters to escape
        // ? & | ! { } [ ] ( ) ^ ~ : + -
        String pat = '(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\:|\\+|\\-)';
        return escapedText.replaceAll(pat, '\\\\$1').trim();
    }
}
