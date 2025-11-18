import { Stack, router } from "expo-router";
import { useEffect } from "react";
import { AppState } from "react-native";
import { supabase } from "../lib/supabase";

AppState.addEventListener('change', async (state) => {
  if (state === 'active') {
    await supabase.auth.startAutoRefresh()
  } else {
    await supabase.auth.stopAutoRefresh()
  }
})

export default function RootLayout() {

  useEffect(() => {
    const { data } = supabase.auth.onAuthStateChange((event, session) => {
      if (session && session.user) {
        router.replace('/(tabs)/configuracoes')
      } else {
        router.replace('/');
      }
    })

    return data.subscription?.unsubscribe
  }, [])

  return <Stack>
    <Stack.Screen
      name="index"
      options={{
        headerShown: false
      }}
    />
    <Stack.Screen
      name="(tabs)"
      options={{
        headerShown: false
      }}
    />
  </Stack>;
}
