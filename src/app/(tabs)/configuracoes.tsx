import { MaterialIcons } from "@expo/vector-icons";
import React, { useState } from "react";
import {
    Image,
    Pressable,
    StyleSheet,
    Text,
    View
} from "react-native";

type UserInfo = {
    name: string;
    email: string;
    avatarUrl?: string;
};

export default function Configuracoes() {
    const [user, setUser] = useState<UserInfo | null>(null);

    const handleSignOut = async () => {
        
    };

    const avatarSource = user?.avatarUrl
        ? { uri: user.avatarUrl }
        : { uri: "https://i.pravatar.cc" };

    return (
        <View style={styles.screen}>
            <View style={styles.profileSection}>
                <View style={styles.avatarWrapper}>
                    <Image source={avatarSource} style={styles.avatar} />
                </View>
                <Text style={styles.name}>{user?.name ?? "Nome do usuário"}</Text>
                <Text style={styles.email}>
                    {user?.email ?? "E-mail do usuário"}
                </Text>
            </View>

            <View style={styles.divider} />

            <Text style={styles.sectionLabel}>AÇÕES DA CONTA</Text>

            <Pressable onPress={handleSignOut} style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}>
                <View style={styles.rowLeft}>
                    <View style={styles.iconPill}>
                        <MaterialIcons name="logout" size={20} color="#e23d3d" />
                    </View>
                    <Text style={styles.rowText}>Sair</Text>
                </View>
                <MaterialIcons name="chevron-right" size={24} color="#a1a1a1" />
            </Pressable>
        </View>
    );
}

const styles = StyleSheet.create({
    screen: {
        flex: 1,
        backgroundColor: "#f6f7f8",
        padding: 16,
    },
    card: {
        flex: 1,
        backgroundColor: "#fff",
        borderRadius: 16,
        paddingVertical: 16,
        paddingHorizontal: 16,
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.1,
        shadowRadius: 12,
        elevation: 4,
    },
    title: {
        textAlign: "center",
        fontSize: 16,
        fontWeight: "600",
        color: "#222",
    },
    profileSection: {
        alignItems: "center",
        paddingVertical: 24,
        gap: 8,
    },
    avatarWrapper: {
        width: 96,
        height: 96,
        borderRadius: 48,
        borderWidth: 3,
        borderColor: "#2F80ED",
        padding: 3,
        justifyContent: "center",
        alignItems: "center",
        marginBottom: 8,
    },
    avatar: {
        width: 90,
        height: 90,
        borderRadius: 45,
    },
    name: {
        fontSize: 18,
        fontWeight: "700",
        color: "#111",
    },
    email: {
        fontSize: 12,
        color: "#7a7a7a",
    },
    divider: {
        height: 1,
        backgroundColor: "#eee",
        marginVertical: 12,
    },
    sectionLabel: {
        fontSize: 12,
        fontWeight: "700",
        color: "#9aa0a6",
        marginBottom: 8,
    },
    row: {
        backgroundColor: "#fafafa",
        borderRadius: 12,
        paddingVertical: 14,
        paddingHorizontal: 12,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        borderWidth: 1,
        borderColor: "#f0f0f0",
    },
    rowPressed: {
        opacity: 0.8,
    },
    rowLeft: {
        flexDirection: "row",
        alignItems: "center",
        gap: 12,
    },
    iconPill: {
        width: 32,
        height: 32,
        borderRadius: 8,
        backgroundColor: "#feecec",
        justifyContent: "center",
        alignItems: "center",
        borderWidth: 1,
        borderColor: "#fde2e2",
    },
    rowText: {
        fontSize: 16,
        color: "#d93025",
        fontWeight: "600",
    },
});