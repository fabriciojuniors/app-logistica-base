import { Alert, KeyboardAvoidingView, ScrollView, StyleSheet, Text, TouchableOpacity, View } from "react-native";

import { MaterialIcons } from '@expo/vector-icons';
import { zodResolver } from '@hookform/resolvers/zod';
import { router } from "expo-router";
import { useForm } from "react-hook-form";
import { Login, loginSchema } from "../@types/login.type";
import { Input } from "../components/Input";
import { supabase } from "../lib/supabase";

export default function Index() {

  const { control, handleSubmit, formState: {errors} } = useForm<Login>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      senha: ''
    }
  })

  const autenticar = async (loginForm: Login) => {
    try {
      const {data, error} = await supabase.auth.signInWithPassword({
        email: loginForm.email,
        password: loginForm.senha
      });
      
      if (error) {
        console.log('Erro ao autenticar!', error);
        throw error;        
      }

      if (data && data.session) {
        router.replace('/(tabs)/configuracoes');
      }
    } catch(e) {
      Alert.alert('Atenção!', 'Usuário ou senha inválidos!')
    }    
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={'padding'}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <View style={styles.iconContainer}>
            <MaterialIcons
              name="local-shipping"
              size={48}
              color="#FFF" />
          </View>
          <Text style={styles.title}>Bem-vindo</Text>
          <Text style={styles.subtitle}>Acesse sua conta para continuar.</Text>
        </View>

        <View style={styles.formContainer}>
          <Input
            nome="email"
            formControl={control}
            label="E-mail"
            placeholder="exemplo@email.com"
            keyboardType="email-address"
            erro={errors.email?.message}
            icone={() =>
              <MaterialIcons
                name="person-outline"
                size={20}
                color={"#666"}
              />}
          />
          <Input
            nome="senha"
            formControl={control}
            label="Senha"
            secureTextEntry
            erro={errors.senha?.message}
            icone={() =>
              <MaterialIcons
                name="lock-outline"
                size={20}
                color={"#666"}
              />}
          />

          <TouchableOpacity style={styles.button} onPress={handleSubmit(autenticar)}>
            <Text style={styles.buttonText}>Entrar</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFF',
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 24,
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: 16,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  formContainer: {
    width: '100%',
  },
  button: {
    backgroundColor: '#007AFF',
    borderRadius: 8,
    height: 50,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 8,
  },
  buttonDisabled: {
    opacity: 0.6,
  },
  buttonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  forgotPasswordButton: {
    marginTop: 16,
    alignItems: 'center',
  },
  forgotPasswordText: {
    color: '#007AFF',
    fontSize: 14,
    fontWeight: '500',
  },
});
