from tree_sitter import Language, Parser
import tree_sitter_c as tsc

def parse_function_signature(c_code: str) -> dict:
    C_LANGUAGE = Language(tsc.language())
    parser = Parser(C_LANGUAGE)
    
    tree = parser.parse(bytes(c_code, 'utf8'))
    root = tree.root_node
    
    result = {}
    
    for node in root.children:
        if node.type == 'function_definition':
            return_type = node.child_by_field_name('type').text.decode()
            declarator = node.child_by_field_name('declarator')
            func_name = declarator.child_by_field_name('declarator').text.decode()
            
            params = []
            param_list = declarator.child_by_field_name('parameters')
            for param in param_list.named_children:
                if param.type == 'parameter_declaration':
                    param_type = param.child_by_field_name('type').text.decode()
                    param_name = param.child_by_field_name('declarator').text.decode()
                    params.append({
                        'type': param_type,
                        'name': param_name
                    })
            
            result = {
                'return_type': return_type,
                'name': func_name,
                'params': params
            }
    
    return result