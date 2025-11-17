import { MaterialIcons } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import { StyleSheet, Text, TouchableOpacity, View } from "react-native";
import { PedidoListItem } from "../@types/PedidoListItem.type";

export default function Pedido({ item }: { item: PedidoListItem }) {
    const router = useRouter()

    const itensCount = (item.itens_pedido ?? []).reduce(
        (acc, it) => acc + (it.quantidade ?? 0),
        0
    );

    const iniciarEntregar = () => {
        //router.push(`/(tabs)/pedidos/entrega/${item.id}`);
    }

    return (
        <View style={styles.card}>
            <View style={styles.cardHeader}>
                <Text style={styles.cardTitle}>{`Pedido #${item.id.substring(0, 5)}`}</Text>
                <Text style={styles.cardItems}>{`${itensCount} itens`}</Text>
            </View>
            <Text style={styles.address} numberOfLines={2}>
                {item.localizacao}
            </Text>
            <TouchableOpacity style={[styles.primaryButton, {backgroundColor: item.status === 'pendente' ? '#2D6CDF' : '#6B7280'}]} activeOpacity={0.8} onPress={iniciarEntregar}>
                <MaterialIcons name="local-shipping" size={20} color="#fff" />
                <Text style={styles.primaryButtonText}>{item.status === 'pendente' ? 'Iniciar Entrega' : 'Continuar entrega'}</Text>
            </TouchableOpacity>
        </View>
    );
}


const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: "#f6f7f8" },
    header: { paddingHorizontal: 16, paddingTop: 12, paddingBottom: 8 },
    headerTitle: { fontSize: 18, fontWeight: "600", color: "#111" },

    searchBox: {
        paddingHorizontal: 16,
        marginBottom: 8,
    },
    searchInput: {
        height: 44,
        borderRadius: 8,
        backgroundColor: "#fff",
        borderWidth: 1,
        borderColor: "#e5e7eb",
        paddingHorizontal: 12,
        color: "#111827",
    },

    listContent: { padding: 16, paddingBottom: 24 },

    card: {
        backgroundColor: "#fff",
        borderRadius: 12,
        padding: 14,
        borderWidth: 1,
        borderColor: "#e5e7eb",
        marginBottom: 12,
        shadowColor: "#000",
        shadowOpacity: 0.05,
        shadowOffset: { width: 0, height: 2 },
        shadowRadius: 6,
        elevation: 1,
    },
    cardHeader: {
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        marginBottom: 6,
    },
    cardTitle: { fontSize: 16, fontWeight: "700", color: "#111" },
    cardItems: { fontSize: 12, color: "#6b7280" },
    address: { fontSize: 13, color: "#374151" },
    metaLine: { marginTop: 4, fontSize: 12, color: "#6b7280" },

    primaryButton: {
        marginTop: 10,
        backgroundColor: "#2D6CDF",
        height: 40,
        borderRadius: 8,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "row",
        gap: 8,
    },
    primaryButtonText: { color: "#fff", fontWeight: "600" },

    center: { flex: 1, alignItems: "center", justifyContent: "center" },
    emptyBox: { alignItems: "center", padding: 24 },
    emptyText: { color: "#6b7280" },
    footerLoading: { paddingVertical: 12 },
});