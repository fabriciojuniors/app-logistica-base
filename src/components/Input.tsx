import {
  StyleSheet,
  Text,
  TextInput,
  TextInputProps,
  View
} from 'react-native';

import { ComponentType } from 'react';
import { Control, Controller } from 'react-hook-form';

interface InputProps extends TextInputProps {
  label?: string,
  nome: string,
  formControl: Control,
  icone?: ComponentType
}

export function Input(props: InputProps) {
  return (
    <View style={styles.container}>
      {props.label && <Text style={styles.label}>{props.label}</Text>}

      <Controller
        name={props.nome}
        control={props.formControl}
        render={({ field }) => (
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              value={field.value}
              onChangeText={field.onChange}
              onBlur={field.onBlur}
              {...props}
            />

            {props.icone &&
              <View style={styles.iconContainer}>
                <props.icone />
              </View>}
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
    fontWeight: '400',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    paddingHorizontal: 16,
    height: 50,
  },
  inputError: {
    borderColor: '#EF4444',
  },
  input: {
    flex: 1,
    fontSize: 16,
    color: '#333',
    paddingVertical: 12,
  },
  iconContainer: {
    marginLeft: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  errorText: {
    fontSize: 12,
    color: '#EF4444',
    marginTop: 4,
    marginLeft: 4,
  },
});
